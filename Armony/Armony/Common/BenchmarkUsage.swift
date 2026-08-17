import Foundation

import BenchPackage001
import BenchPackage002
import BenchPackage003
import BenchPackage004
import BenchPackage005

enum BenchmarkUsage {
    static func touchAll() -> Int {
        var total = 0
        total += BenchPackage001.value()
        total += BenchPackage002.value()
        total += BenchPackage003.value()
        total += BenchPackage004.value()
        total += BenchPackage005.value()
        return total
    }
}
