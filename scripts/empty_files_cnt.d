import std.algorithm;
import std.algorithm.iteration;
import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string;

// Скрипт - ходит по папкам и считает количество пустых cpp файлов
// (не содержащих нормальных строк кода кроме подключения ашников и объявления пространств имен)
// Если выкинуть их из проекта (временно) - радикально уменьшается время компиляции

bool isEmpty(T)( T range ) {
	return range
			.map!(a => a.strip!() ) // выкидываем пробелы
			.filter!( a => !a.empty ) // не считаем пустые строки
			.filter!( a => !a.startsWith!()("#include") )
            .filter!( a => !a.startsWith!()("namespace") )
            .filter!( a => !a.startsWith!()("}") )
            .empty;
			//.array // ??? зачем-то в массив нужно склеивать
			//.length;
}

bool isEmptyFile( string file ) {
    return isEmpty((cast(string) std.file.read(file)).splitLines);
}

void calc( string path ) {
    dirEntries(path, SpanMode.breadth)
        .filter!(a => a.isFile)
        //.filter!(a => a.name.endsWith!()("cpp") || a.name.endsWith!()("h") || a.name.endsWith!()("cxx") || a.name.endsWith!()("hxx") )
        .filter!(a => a.name.endsWith!()("cpp")  )
        //.filter!(a => !(a.name.endsWith!()("_t.cpp") || a.name.endsWith!()("_t.h")) )
        //.filter!(a => !(a.name.endsWith!()("Mock.cpp") || a.name.endsWith!()("Mock.h")) )
        .filter!isEmptyFile
        .map!(a => 1)
        .sum
        .writeln;
}

void main() {
    calc(`F:\Work\DAC\designgui\src\`);
}
