declare variable $classes:=doc('classes.xml')/doc/class;
declare variable $nl:='
';
declare variable $cats:=for $i in
    distinct-values(for $j in $classes/@category
    return $j)
return <cat>{$i}</cat>;
declare function local:quot-pg($s as xs:string) as xs:string {
    (:
         Do not copy this without proper understanding
    :)
    concat("'",replace(replace($s,"'","''"),"\\","\\\\"), "'")
};
declare function local:quot($s as xs:string) as xs:string{
    local:quot-pg($s)
};

declare function local:numeric-id($node as node()) as xs:string {
    fn:substring-after(fn:generate-id($node),'id')
};

declare function local:find-class($c as xs:string) as xs:string {
    let $aClass := $classes[@name=$c]
    return if ($aClass) then
        local:numeric-id($aClass)
    else
        'NULL'
};

(: meow :)
declare function local:find-cat($c as xs:string) as xs:string {
    let $aCat := $cats[text()=$c]
    return if ($aCat) then
        local:numeric-id($aCat)
    else
        'NULL'
};

(

    for $cat in $cats
    return concat('INSERT INTO categories(id,label) VALUES(',local:numeric-id($cat),',',local:quot(fn:string($cat)),');')
    ,
    for $class in $classes
    order by $class/@inherits
    let $class-id:=local:numeric-id($class)
    return (
            concat(
                    'INSERT INTO classes(id,parent_class,short_desc,long_desc,name,category) VALUES(',
                    $class-id, ',',
                    local:find-class(($class/@inherits, '')[1]), ',',
                    local:quot($class/brief_description), ',',
                    local:quot($class/description), ',',
                    local:quot($class/@name),',',
                    local:find-cat($class/@category),
                    ');'
            ),
        for $method in $class/methods/method
        let $method-id:=local:numeric-id($method)
        return (

                concat(
                        'INSERT INTO class_methods(id, name, return_type, owner_class, short_desc, long_desc, qualifiers) VALUES(',
                        $method-id, ',',
                        local:quot($method/@name), ',',
                        local:quot(($method/return/@type, 'void')[1]), ',',
                        local:numeric-id($class), ',',
                        '''''', ',', (: Unused for now :)
                        local:quot(($method/description)), ',',
                        local:quot(($method/@qualifiers, '')[1]),
                        ');'
                ),

            for $argument in $method/argument
            return
                concat(
                        'INSERT INTO godotdoc.method_arguments( id, pos, name, param_type, owner_method, default_value, short_desc) VALUES(',
                        local:numeric-id($argument), ',',
                        local:quot($argument/@index), ',',
                        local:quot($argument/@name), ',',
                        local:quot($argument/@type), ',',
                        $method-id, ',',
                        if ($argument/@default) then (local:quot($argument/@default)) else ('NULL'), ',',
                        local:quot(data($argument)),
                        ');'
                )
        ),
        for $signal in $class/signals/signal
        let $signal-id:=local:numeric-id($signal)
        return (

                concat(
                        'INSERT INTO godotdoc.class_signals( id, name, owner_class, long_desc) VALUES(',
                        $signal-id, ',',
                        local:quot($signal/@name), ',',
                        $class-id, ',',
                        local:quot($signal/description),
                        ');'
                ),
            for $argument in $signal/argument
            return
                concat(
                        'INSERT INTO godotdoc.signal_arguments( id, pos, name, param_type, owner_signal, short_desc) VALUES(',
                        local:numeric-id($argument), ',',
                        local:quot($argument/@index), ',',
                        local:quot($argument/@name), ',',
                        local:quot($argument/@type), ',',
                        $signal-id, ',',
                        local:quot(data($argument)),
                        ');'
                )
        ),
        for $constant in $class/constants/constant
        return
            concat(
                    'INSERT INTO godotdoc.class_constants( id, name, const_value, long_desc, owner_class) VALUES(',
                    local:numeric-id($constant),',',
                    local:quot($constant/@name),',',
                    local:quot($constant/@value),',',
                    local:quot(data($constant)),',',
                    $class-id,
                    ');'


            )
    )


)