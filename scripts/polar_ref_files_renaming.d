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
после проведения глобальных рефакторингов поляризаций и поляризационных базисов в проекте
возникале потребность переименовывать и перегруппировывать файлы с автогенерируемыми тестовыми 
данными
*/

//----------------------------------
bool endsWithS(T)( T file, immutable string e ) {
	return file.name.endsWith!()( e );
}

//----------------------------------
void forEach(alias Functor)( string end = ".bin" ) {
	auto rng = dirEntries("F:/data2", SpanMode.breadth)
		.filter!isFile
		.filter!( a => a.endsWithS( end ) )
		.filter!( a => a.name.indexOf( "tst_") >= 0 );
	foreach ( file; rng ) {
		Functor( file );
	}
}

//----------------------------------
void printName(T)( T str ) {
	str.writeln;
	str.baseName.writeln;
}

//----------------------------------
bool baseNameContains(T)( T file, string str ) {
	return file.baseName.indexOf( str ) >= 0;
}

//----------------------------------
bool coCr(T)( T file ) {
	return file.baseNameContains( "CoCr" );
}

//----------------------------------
string renameEndReturn( string from, string to ) {
	return
		    "if ( true == file.endsWithS( \"" ~from~ "\") ) {
				rename( file, file.replace(\"" ~from~ "\", \"" ~to~ "\") );	
				return;
			}";
}

//----------------------------------
void processElAz(T)( T file ) {
	if ( file.coCr == true ) {
		return;
	}
	if ( file.baseNameContains( "ElAz") == false ) {
		return;
	}
	mixin( renameEndReturn( "_H.bin", "_a.bin" ) );	
	mixin( renameEndReturn( "_V.bin", "_e.bin" ) );	
	mixin( renameEndReturn( "_CoupVH.bin", "_Coupea.bin" ) );	
	mixin( renameEndReturn( "_CoupHV.bin", "_Coupae.bin" ) );	
}

//----------------------------------
void processAzEl(T)( T file ) {
	if ( file.coCr == true ) {
		return;
	}
	if ( file.baseNameContains( "AzEl") == false ) {
		return;
	}
	mixin( renameEndReturn( "_H.bin", "_A.bin" ) );	
	mixin( renameEndReturn( "_V.bin", "_E.bin" ) );	
	mixin( renameEndReturn( "_CoupVH.bin", "_CoupEA.bin" ) );	
	mixin( renameEndReturn( "_CoupHV.bin", "_CoupAE.bin" ) );	
}

//----------------------------------
void processThPh(T)( T file ) {
	if ( file.coCr == true ) {
		return;
	}
	if ( file.baseNameContains( "ThPh") == false ) {
		return;
	}
	mixin( renameEndReturn( "_CoupVH.bin", "_CoupPT.bin" ) );	
	mixin( renameEndReturn( "_CoupHV.bin", "_CoupTP.bin" ) );	
}

//----------------------------------
void processCoCr(T)( T file ) {
	if ( file.coCr == false ) {
		return;
	}

	//----------------------------------
	string removeReturn( string what ) {
		return
			    "if ( true == file.baseNameContains(\"" ~what~ "\") ) {
					remove( file );
					return;
				}";
	}

	// убрать CoCr или удалить

	mixin( removeReturn( "Tilt.bin" ) );	
	mixin( removeReturn( "Axial.bin" ) );	
	mixin( removeReturn( "_L.bin" ) );	
	mixin( removeReturn( "_R.bin" ) );	
	mixin( removeReturn( "_CoupLR.bin" ) );	
	mixin( removeReturn( "_CoupRL.bin" ) );	

	rename( file, file.replace( "CoCr", "" ) );	
}

//----------------------------------
void removeCoCrAllPattShortInfo(T)( T file ) {
	if ( file.coCr == false ) {
		return;
	}

	file.baseName.writeln;
	remove( file );
}

//----------------------------------
void main() {
	forEach!printName;

	{
		int i = 0;
		forEach!( a => i+=1 );
		i.writeln;
	}

	// перед запуском - подумай!!!
	/*forEach!processElAz;
	forEach!processAzEl;
	forEach!processThPh;
	forEach!processCoCr;
	forEach!removeCoCrAllPattShortInfo( "all_info.txt" );*/

	{
		int i = 0;
		forEach!( a => i+=1 );
		i.writeln;
	}
}

