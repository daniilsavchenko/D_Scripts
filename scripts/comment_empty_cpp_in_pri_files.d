import std.stdio;
import std.range;
import std.algorithm;
import std.file;
import std.string;
import std.path;
import std.exception;

// Скрипт: парсит pri файлы в заданной папке, в каждом pri файле рассматривает
// все cpp-шники: открывает их и анализирует на предмет выполняемого кода.
// Если выполняемого кода в cpp файле нет, то комментирует этот файл в pri файле
// Зачем? 1) я привысил лимит на чило файлов в 15-ой студии 2) Время компиляции будет выше

bool isCppFileEmpty( string cpp_file_path ) {
	//cpp_file_path.writeln();
	try {
		return (cast(string)std.file.read( cpp_file_path ))
					.splitLines
					.map!( a => a.strip() )
					.filter!( a => !a.empty() )
					.filter!( a => !a.startsWith!()( "namespace") )
					.filter!( a => !a.startsWith!()( "#include" ) )
					.filter!( a => !a.startsWith!()( "}" ) )
					.filter!( a => !a.startsWith!()( "{" ) )
					.empty();
	} catch ( Exception ) {
		write( "Problem file: " );
		cpp_file_path.writeln();
	}
	return false;
}

bool isCppFileEmpty( string cpp_path_from_pri, string pri_path ) {
	// для упрощения игнорируем cpp файл, которые не начинаются с $$PWD
	if ( false == cpp_path_from_pri.canFind( "$$PWD" ) ) {
		return false;
	}
	// уже содержит комментарий
	if ( true == cpp_path_from_pri.canFind( "#" ) ) {
		return false;
	}
	return isCppFileEmpty( cpp_path_from_pri
							.strip()
							.replace( "$$PWD", pri_path )
							.replace( ".cpp \\", ".cpp" )
							.replace( ".cpp\\", ".cpp" ) );
}

string processPriFileLine( string s, string pri_path, scope ref int counter ) {
	if ( false == s.canFind(".cpp") ) {
		return s;
	}
	// для упрощения игнорируем cpp файл, которые первые
	if ( true == s.canFind("SOURCES") ) {
		return s;
	}
	if ( false == s.isCppFileEmpty( pri_path ) ) {
		return s;
	}
	//s.writeln();
	counter++;
	return "#EMPTY_CPP_FILE" ~ s;
}

void processPriFile( string file_name, scope ref int counter ) {
	immutable base_file_name = baseName( file_name );
	immutable src_dir = dirName( file_name );
	//file_name.writeln();

	//immutable lines =
	(cast(string)std.file.read( file_name ))
				.splitLines
				.map!( a => a.processPriFileLine( src_dir, counter ) )
				.map!( a => a ~ '\n' )
				.toFile( file_name );
}

void main( string[] args ) {
	auto src_dir = args[1];
	int counter = 0;
	foreach ( file;
		dirEntries( src_dir, SpanMode.depth )
		.filter!( a => a.isFile() )
		.filter!( a => a.name.endsWith!()( ".pri" ) )
		//.filter!( a => !a.name.endsWith!()( "settings.pri" ) )
	){
		processPriFile( file, counter );
	}
	writeln( "Commented files = ", counter );
}
