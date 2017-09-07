import std.algorithm;
import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string;
//import std.conv.parse;
import std.conv;
import std.math;

// Скрипт для фильтрации и обработкилиний равного уровня для Юрий Николаевича

struct Pair {
    double d1, d2;
}

Pair toPair( string s ) {
    double d1 = parse!double(s);
    s = s.stripLeft();
    double d2 = parse!double(s);
    //writeln( d1, ' ', d2 );
    return Pair(d1, d2);

    /*T opBinary(string op)(T rhs)
    {
        static if (op == "+") return data + rhs.data;
        else static if (op == "-") return data - rhs.data;
        else static assert(0, "Operator "~op~" not implemented");
    }*/
};

bool cmpPair( Pair d1, Pair d2 ) {
    if ( d1.d1 < d2.d1 )
        return true;
    if ( d1.d1 > d2.d1 )
        return false;
    if ( d1.d2 < d2.d2 )
        return true;
    if ( d1.d2 > d2.d2 )
        return false;
    return false;
}


bool cmpDbl( double d1, double d2 ) {
    immutable mul = 10000.;
    return to!int(d1*mul) == to!int(d2*mul);
}

auto sq(T)( T s ) {
    return s*s;
}

size_t findNearest( Pair[] data, Pair p ) {
    double length = 10000000;
    size_t ind = 0;
    foreach( i, d; data ) {
        double l = sqrt( sq(p.d1 - d.d1) + sq( p.d2 - d.d2 ) );
        if ( l < length ) {
            length = l;
            ind = i;
        }
    }
    return ind;
}

auto sortData( Pair[] p ) {
    Pair[] result = [ p[0] ];
    auto set = p[1..$].dup;
    while ( set.empty == false ) {
        auto ind = findNearest( set, result[$-1]);
        result ~= set[ ind ];
        set = set[0..ind] ~ set[ind+1..$];
    }
    result ~= result[0];
    return result;
}

void calc( string path ) {
    auto data = (cast(string) std.file.read(path))
        .splitLines
        .array[2..$]
        .sort()
        .map!toPair
        .array;
    auto data2 = data
        //.sort!cmpPair
        //.array    
        .uniq!( (a,b) => cmpDbl( a.d1, b.d1 ) && cmpDbl( a.d2, b.d2 ) )
        .array;
    //writeln( data2 );        
    writeln( path, ' ', data.length, ' ', data2.length, ' ', data2.length*2 );
    //assert( data.length == data2.length*2);
    data2
        .sortData
        .map!( a => to!string(a.d1) ~ '\t' ~to!string(a.d2) ~ '\n' )
        .toFile( path );
}

void main() {
    //calc(`F:\Work\DAC\designgui\src\Repository\MeasRepoSQLImpl`);
    calc(`Z:\Savchenko\AviaRadar\3\R1_3.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R1_07.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R1_82.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R2_3.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R2_07.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R2_82.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R3_3.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R3_07.txt`);
    calc(`Z:\Savchenko\AviaRadar\3\R3_82.txt`);
}
