import std.stdio;
alias io = std.stdio;
import std.range;
import std.algorithm.iteration;
import std.file;
alias file = std.file;

// Скрипт: в некоторое папке заменяет строчку в названии файлов на другую

void main() {
	foreach ( name; dirEntries("F:/ARenamingFiles", SpanMode.breadth)) {
	    rename( name, name.replace( "FFThPh", "FFAzEl" ) );
	}
}

