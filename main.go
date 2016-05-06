package main

import (
	_ "github.com/lib/pq"
	"github.com/jmoiron/sqlx"
)

type Category struct{
	Id int `db:"cat_id"`
	Label string `db:"cat_label"`
}
type Class struct{
	Id int
	Parent int
	ShortDesc string
	LongDesc string
	Name string
}
type Method struct{
	Id int
	Owner int
	Name string
	ShortDesc string
	LongDesc string
	ReturnType string
	Qualifiers string
}

type Argument struct{
	Id int
	Owner int
	Position int
	Name string
	ShortDesc string
	Type string
	DefaultValue string
}

type Constant struct{
	Id int
	Owner int
	Name string
	Value string
}

func main() {

	db:=sqlx.MustOpen("postgres","user=godotdoc dbname=godotdoc password=1234 sslmode=disable")
	defer db.Close()
	db.Ping()
	_,e:=db.Exec(`INSERT INTO categories(label) VALUES(?)`)
	if e!=nil {
		panic(e)
	}
}