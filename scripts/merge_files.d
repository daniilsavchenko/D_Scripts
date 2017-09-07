import std.stdio;
import std.range;
import std.algorithm;
import std.file;
import std.string;
import std.path;

// Скрипт: берет несколько наборы файлов (cpp и h) и достаточно интеллектуально
// соединяет их в меньшее количество файлов (cpp и h)

void appendHFile(T)( ref string[] file, T input ) {
	// вставили описание класса
	file ~= "\n//--------------------------------\n//--------------------------------\n//--------------------------------\n";
	foreach( line; input
				// выделили описание класса
				.find!(a => a.startsWith( "class") )
				.until!( a => a.startsWith( "};") )( No.openRight ) ) {
		file ~= line ~ "\n";
	}
	file ~= "\n";
	// а еще выделили все инклуды и дописали (на общей обработке мы их достанем отсортируем и выкинем повторы)
	foreach( line; input.filter!( a => a.startsWith( "#include") ) ) {
		file ~= line ~ "\n";
	}
}

void appendCFile(T)( ref string[] file, T input ) {
	file ~= "\n//--------------------------------\n";
	foreach( line; input
				// удалили пустые строки
				.filter!( a => a.strip().empty() == false )
				// удалили разметку
				.filter!( a => a.startsWith("#include") == false)
				.filter!( a => a.startsWith("namespace") == false)
				.filter!( a => a.startsWith("} //") == false ) ) {
		file ~= line ~ "\n";
	}
}

// для каждой группы файлов - содержимое цпп и аш
struct OutFilesData {
	string[] h_file;
	string[] c_file;
}

// тип мапы из имен групп файлов в содержимое
alias FileGroupMap = OutFilesData[string];

ref OutFilesData chooseOutFileStruct( FileGroupMap file_group_map, immutable string name ) {
	foreach ( n, ref arr; file_group_map ) {
		if ( name.startsWith( n ) )
			return arr;
	}
	throw new Exception( "I don't know what this file group: " ~ name );
}

void collectInputFiles( string path_from, ref FileGroupMap file_group_map ) {
    foreach( f; dirEntries( path_from, SpanMode.breadth )
    	        .filter!( a => a.isFile ) ) {
 	    immutable name = baseName( f ); 
	    auto content = (cast(string) std.file.read(f)).splitLines;
	    if ( true == name.endsWith("cpp") ) {
	   		appendCFile( chooseOutFileStruct( file_group_map, name ).c_file, content );
	    } else if ( true == name.endsWith("h") ) {
			appendHFile( chooseOutFileStruct( file_group_map, name ).h_file, content );
	    }
	}
}

string[] prepareResultHeader( string subname, string[] content ) {
	// разделяем содержимое, код классов должен быть внутри неймспейса, а инклуды - снаружи
	const reg_code = content.filter!( a => false == a.startsWith("#include") ).array;
	//const inc_code = std.algorithm.sort(content.filter!( a => true == a.startsWith("#include") ).array).uniq.array;
	const inc_code = content.filter!( a => true == a.startsWith("#include") ).array.sort().uniq.array;
	immutable guard = "TRIM_" ~ toUpper( subname ) ~ "_H";
	return [ "#ifndef " ~ guard ] ~
		   [ "\n#define " ~ guard ~ "\n\n" ] ~
		   inc_code ~
		   [ "\nnamespace trim {\n"] ~
		   reg_code ~
		   [ "} // namespace trim\n\n"] ~
		   [ "#endif // " ~ guard ];
}

string[] prepareResultCpp( string subname, string[] content ) {
	// разделяем содержимое, код должен быть внутри неймспейса, а код сериализации - в конце файла
	const reg_code = content.filter!( a => false == a.startsWith("CFDX_SERIAL_EXPORT") ).array;
	const ser_code = content.filter!( a => true == a.startsWith("CFDX_SERIAL_EXPORT") ).array;
	return [ "#include \"" ~ subname ~ ".h\"\n" ] ~
		   [ "#include <Serialization/SerializationExportX.h>\n" ] ~
	       [ "\nnamespace trim {\n"] ~
		   reg_code ~
		   [ "\n} // namespace trim\n\n"] ~
		   ser_code;
}

void printResultFilesPair( string subname, OutFilesData content, string path ) {
	immutable full_name = subname ~ "byXx_Recalculator";
	prepareResultHeader( full_name, content.h_file ).toFile( path ~ full_name ~ ".h" );
	prepareResultCpp( full_name, content.c_file ).toFile( path ~ full_name ~ ".cpp" );
}


void main() {
	FileGroupMap file_group_map = [
		//"PCV1FFThPh_AlphaEl_": OutFilesData(),
		"PCV1FFThPh_AzEl_": OutFilesData(),
		//"PCV1FFThPh_CoCrAzEl_": OutFilesData(),
		"PCV1FFThPh_CoCrThPh_": OutFilesData(),
		"PCV1FFThPh_ElAz_": OutFilesData(),
		"PCV1FFThPh_ThPh_": OutFilesData()
	];

	collectInputFiles( "F:/D_Stuff/Files mergin", file_group_map );

	foreach ( name, content; file_group_map ) {
		printResultFilesPair( name, content, "F:/D_Stuff/Files mergin/Result/" );
	}
}



/*
// убираем лишнее из pri файла

bool contains( string s, immutable string c ) {
	return s.indexOf( c ) >= 0;
}

void main() {
	(cast(string) std.file.read("F:/D_Stuff/Files mergin/PCV1Srcs_model.pri"))
		.splitLines
		.filter!( a => false == (a.contains( "PCV1NF" ) && a.contains( "_by" )) )
		.filter!( a => false == (a.contains( "PCV1FF" ) && a.contains( "_by" )) )
		.map!( a => a ~ "\n" )
		.toFile( "F:/D_Stuff/Files mergin/Result/PCV1Srcs_model.pri" );
}*/