xquery version '3.0';

declare function local:nest-inherit($e as element()*){
    if ($e) then
    for $i in $e
    let $parent:=string($i/@inherits)
    group by $parent
    return
            <class name="{$parent}">
                {
                    local:nest-inherit(local:remove-inherits($i[@inherits],$parent)),
                    $i[not(@inherits)]
                }

            </class>
    else
    ()
};

declare function local:remove-inherits($e as element()*,$v as xs:string){
    for $i in $e
    return
        element {fn:node-name($i)} {
            $i/@*[name()!='inherits' and string()!=$v],
            $i/node()
        }
};

declare function local:test(){
    <doc>
        <class inherits="ok" bar="foo1">
        </class>
        <class inherits="ok" bar="foo2">
        </class>
        <class inherits="ok" bar="foo3">
        </class>
    </doc>
};

let $classes:= doc('classes.xml')/doc/class
return <doc>{local:nest-inherit($classes[@inherits]),$classes[not(@inherits)]}</doc>