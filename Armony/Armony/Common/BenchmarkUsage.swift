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
import BenchPackage021
import BenchPackage022
import BenchPackage023
import BenchPackage024
import BenchPackage025
import BenchPackage026
import BenchPackage027
import BenchPackage028
import BenchPackage029
import BenchPackage030
import BenchPackage031
import BenchPackage032
import BenchPackage033
import BenchPackage034
import BenchPackage035
import BenchPackage036
import BenchPackage037
import BenchPackage038
import BenchPackage039
import BenchPackage040
import BenchPackage041
import BenchPackage042
import BenchPackage043
import BenchPackage044
import BenchPackage045
import BenchPackage046
import BenchPackage047
import BenchPackage048
import BenchPackage049
import BenchPackage050
import BenchPackage051
import BenchPackage052
import BenchPackage053
import BenchPackage054
import BenchPackage055
import BenchPackage056
import BenchPackage057
import BenchPackage058
import BenchPackage059
import BenchPackage060
import BenchPackage061
import BenchPackage062
import BenchPackage063
import BenchPackage064
import BenchPackage065
import BenchPackage066
import BenchPackage067
import BenchPackage068
import BenchPackage069
import BenchPackage070
import BenchPackage071
import BenchPackage072
import BenchPackage073
import BenchPackage074
import BenchPackage075
import BenchPackage076
import BenchPackage077
import BenchPackage078
import BenchPackage079
import BenchPackage080
import BenchPackage081
import BenchPackage082
import BenchPackage083
import BenchPackage084
import BenchPackage085
import BenchPackage086
import BenchPackage087
import BenchPackage088
import BenchPackage089
import BenchPackage090
import BenchPackage091
import BenchPackage092
import BenchPackage093
import BenchPackage094
import BenchPackage095
import BenchPackage096
import BenchPackage097
import BenchPackage098
import BenchPackage099
import BenchPackage100

enum BenchmarkUsage {
    @discardableResult
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
        total += BenchPackage021.value()
        total += BenchPackage022.value()
        total += BenchPackage023.value()
        total += BenchPackage024.value()
        total += BenchPackage025.value()
        total += BenchPackage026.value()
        total += BenchPackage027.value()
        total += BenchPackage028.value()
        total += BenchPackage029.value()
        total += BenchPackage030.value()
        total += BenchPackage031.value()
        total += BenchPackage032.value()
        total += BenchPackage033.value()
        total += BenchPackage034.value()
        total += BenchPackage035.value()
        total += BenchPackage036.value()
        total += BenchPackage037.value()
        total += BenchPackage038.value()
        total += BenchPackage039.value()
        total += BenchPackage040.value()
        total += BenchPackage041.value()
        total += BenchPackage042.value()
        total += BenchPackage043.value()
        total += BenchPackage044.value()
        total += BenchPackage045.value()
        total += BenchPackage046.value()
        total += BenchPackage047.value()
        total += BenchPackage048.value()
        total += BenchPackage049.value()
        total += BenchPackage050.value()
        total += BenchPackage051.value()
        total += BenchPackage052.value()
        total += BenchPackage053.value()
        total += BenchPackage054.value()
        total += BenchPackage055.value()
        total += BenchPackage056.value()
        total += BenchPackage057.value()
        total += BenchPackage058.value()
        total += BenchPackage059.value()
        total += BenchPackage060.value()
        total += BenchPackage061.value()
        total += BenchPackage062.value()
        total += BenchPackage063.value()
        total += BenchPackage064.value()
        total += BenchPackage065.value()
        total += BenchPackage066.value()
        total += BenchPackage067.value()
        total += BenchPackage068.value()
        total += BenchPackage069.value()
        total += BenchPackage070.value()
        total += BenchPackage071.value()
        total += BenchPackage072.value()
        total += BenchPackage073.value()
        total += BenchPackage074.value()
        total += BenchPackage075.value()
        total += BenchPackage076.value()
        total += BenchPackage077.value()
        total += BenchPackage078.value()
        total += BenchPackage079.value()
        total += BenchPackage080.value()
        total += BenchPackage081.value()
        total += BenchPackage082.value()
        total += BenchPackage083.value()
        total += BenchPackage084.value()
        total += BenchPackage085.value()
        total += BenchPackage086.value()
        total += BenchPackage087.value()
        total += BenchPackage088.value()
        total += BenchPackage089.value()
        total += BenchPackage090.value()
        total += BenchPackage091.value()
        total += BenchPackage092.value()
        total += BenchPackage093.value()
        total += BenchPackage094.value()
        total += BenchPackage095.value()
        total += BenchPackage096.value()
        total += BenchPackage097.value()
        total += BenchPackage098.value()
        total += BenchPackage099.value()
        total += BenchPackage100.value()
        UserDefaults.standard.set(total, forKey: "BenchmarkUsageTotal")
        return total
    }
}
