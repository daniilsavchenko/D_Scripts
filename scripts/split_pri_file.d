import std.stdio;
import std.range;
import std.algorithm;
import std.file;
import std.string;
import std.path;

// Скрипт: парсит pri файлы и создает два других pri файла - один со всеми 
// h и cpp модельного слоя, второй - слоя представления данных

auto iarray(Range)( Range rng ) {
	return rng.array.idup;
}

string genPriFileName_And_MakeResultDir( string source_name, string new_postfix ) {
	assert( source_name.endsWith!()( ".pri" ) );
	return makeResultDir( source_name ) ~ baseName( source_name )[0..$-4] ~ new_postfix ~ ".pri";
}

string makeResultDir( string src_file_name ) {
	immutable res_dir_name = dirName( src_file_name ) ~ "/result/";
	res_dir_name.mkdirRecurse();
	return res_dir_name;
}

auto proccesPriFileSibLines( Range )( Range rng ) {
	immutable endl_str = " \\\n";
	immutable space_str = "    ";
	auto lines_separators_rng = chain( rng.drop(1).map!( a => endl_str ), ["\n\n"] );
	auto lines_starts_rng = chain( [""], rng.drop(1).map!( a => space_str ) );
	return rng.zip( lines_starts_rng, lines_separators_rng ).map!"a[1]~a[0]~a[2]";
}

void makePriFile(Range)( string file_name, Range lines ) {
	immutable cpp_files = "SOURCES += " ~
			lines
			.filter!( a => a.endsWith!()( ".cpp" ) )
			.iarray;
	immutable h_files = "HEADERS += " ~
			lines
			.filter!( a => a.endsWith!()( ".h" ) )
			.iarray;			
	immutable qrc_files = "RESOURCES += " ~
			lines
			.filter!( a => a.endsWith!()( ".qrc" ) )
			.iarray;
	assert( cpp_files.length + h_files.length + qrc_files.length == lines.iarray.length + 3 );

	chain( proccesPriFileSibLines( h_files ),  proccesPriFileSibLines( cpp_files ),  proccesPriFileSibLines( qrc_files ) )
		.toFile( file_name );
}

void makeMainPriFile(Range)( string src_file_name, Range sub_files ) {
	immutable res_dir_name = makeResultDir( src_file_name );
	immutable file_name = res_dir_name ~ baseName( src_file_name );
	
	sub_files
		.map!( a => "include(" ~ baseName(a) ~ ")\n" )
		.toFile( file_name );
}

void processPriFile( string file_name ) {
	immutable base_file_name = baseName( file_name );
	immutable src_dir = dirName( file_name );

	immutable lines = (cast(string)std.file.read( file_name ))
				.splitLines
				.map!( a => a.strip() )
				// удалили пустые строки
				.filter!( a => a.empty() == false )
				// удалили разметку
				.filter!( a => a.startsWith!()("HEADER") == false)
				.filter!( a => a.startsWith!()("SOUR") == false)
				.filter!( a => a.startsWith!()("RESOU") == false )
				// удалили переносы строк
				.map!( a => a.endsWith!()( '\\' ) ? a[0..$-1] : a )
				.map!( a => a.strip() )
				// в массив
				.iarray;
	
	immutable pre_file_name = genPriFileName_And_MakeResultDir( file_name, "_pres" );
	makePriFile( pre_file_name
		, lines.filter!( a => a.canFind( "Present" ) )  );

	immutable mod_file_name = genPriFileName_And_MakeResultDir( file_name, "_model" );
	makePriFile( mod_file_name
		, lines.filter!( a => a.canFind( "Present" ) == false )  );

	makeMainPriFile( file_name, [mod_file_name, pre_file_name ] );
}

void main() {
	immutable src_dir = "F:/D_Stuff/PriFiles";
	foreach ( file;
		dirEntries( src_dir, SpanMode.shallow )
		.filter!( a => a.isFile() )
		.filter!( a => a.name.endsWith!()( ".pri" ) ) ) {
		processPriFile( file );
	}
}
