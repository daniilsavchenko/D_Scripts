import std.stdio;
alias io = std.stdio;
import std.range;
import std.algorithm.iteration;
import std.file;
import std.string;
import std.path;
alias file = std.file;

// Скрипт:
/*
выводит / удаляет файлики по заданным критериям
*/

//----------------------------------
bool endsWithS(T)( T file, immutable string e ) {
	return file.name.endsWith!()( e );
}

//----------------------------------
void forEach(alias Functor)( string end = "" ) {
	auto rng = dirEntries("F:/Work/DAC/designgui", SpanMode.breadth)
		.filter!isFile
		.filter!( a => a.endsWithS( end ) );
	foreach ( file; rng ) {
		Functor( file );
	}
}

//----------------------------------
bool baseNameContains(T)( T file, string str ) {
	return file.baseName.indexOf( str ) >= 0;
}

//----------------------------------
void main() {
	//alias action = writeln;
	void action2(T)( T a ){
		if ( a.baseNameContains( "_byPhi" ) ) {
			writeln(a);
		}
	};
	alias action = a => action2(a);
	forEach!action( ".h" );
	forEach!action( ".cpp" );

	//void action2(T)( T a ){
	//	if ( a.baseNameContains( "tst_" ) ) {
	//		action(a);
	//	}
	//};
	//forEach!(a => action2(a) )( "all_info.txt" );
}

