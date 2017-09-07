import std.algorithm;
import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string;

// Скрипт ходит по папкам и считает количество строк в исходниках
// самым тупым образом

int sutableStringsCount(T)( T range ) {
	return range
			.map!(a => a.strip!() ) // выкидываем пробелы
			.filter!( a => !a.empty ) // не считаем пустые строки
			//.filter!( a => !a.startsWith!()("//") ) // не комментарии
			.array // ??? зачем-то в массив нужно склеивать
			.length;
}

void calc( string path ) {
    dirEntries(path, SpanMode.breadth)
        .filter!(a => a.isFile)
        //.filter!(a => a.name.endsWith!()("cpp") || a.name.endsWith!()("h") || a.name.endsWith!()("cxx") || a.name.endsWith!()("hxx") )
        .filter!(a => a.name.endsWith!()("cpp") || a.name.endsWith!()("h") || a.name.endsWith!()("qml")
            //|| a.name.endsWith!()("cxx") || a.name.endsWith!()("hxx")
         )
        .filter!(a => a.name.find( "_PROJEC" ).empty() )
        //.filter!(a => a.name.find( "Presentation" ).empty() )
        //.filter!(a => a.name.find( "G2D" ).empty() )
        //.filter!(a => a.name.find( "G3D" ).empty() )
        //.filter!(a => a.name.find( "Widget" ).empty() )
        //.filter!(a => !(a.name.endsWith!()("_t.cpp") || a.name.endsWith!()("_t.h")) )
        //.filter!(a => !(a.name.endsWith!()("Mock.cpp") || a.name.endsWith!()("Mock.h")) )
        .map!(a => (cast(string) std.file.read(a)))
        .map!(a => a.splitLines)
        .map!sutableStringsCount
        .sum
        .writeln;
}

void main() {
    //calc(`F:\Work\DAC\designgui\src\Repository\MeasRepoSQLImpl`);
    calc(`F:\Work\DAC\designgui\src\`);
}
