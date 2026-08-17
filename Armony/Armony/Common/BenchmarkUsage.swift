import Foundation

import BenchPackage001
import BenchPackage002
import BenchPackage003
import BenchPackage004
import BenchPackage005
import BenchPackage006
import BenchPackage007
import BenchPackage008
import BenchPackage009
import BenchPackage010
import BenchPackage011
import BenchPackage012
import BenchPackage013
import BenchPackage014
import BenchPackage015
import BenchPackage016
import BenchPackage017
import BenchPackage018
import BenchPackage019
import BenchPackage020

enum BenchmarkUsage {
    static func touchAll() -> Int {
        var total = 0
        total += BenchPackage001.value()
        total += BenchPackage002.value()
        total += BenchPackage003.value()
        total += BenchPackage004.value()
        total += BenchPackage005.value()
        total += BenchPackage006.value()
        total += BenchPackage007.value()
        total += BenchPackage008.value()
        total += BenchPackage009.value()
        total += BenchPackage010.value()
        total += BenchPackage011.value()
        total += BenchPackage012.value()
        total += BenchPackage013.value()
        total += BenchPackage014.value()
        total += BenchPackage015.value()
        total += BenchPackage016.value()
        total += BenchPackage017.value()
        total += BenchPackage018.value()
        total += BenchPackage019.value()
        total += BenchPackage020.value()
        return total
    }
}
