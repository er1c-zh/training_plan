//
// Created by eric on 2022/8/31.
//

import Foundation

struct Generator {
    static public func gen(etList: [ExerciseType]) -> [Record.Data] {
        var l: [Record.Data] = []
        for et in etList {
            var latest: Record?
            if let doneRecord = Record.getLastDoneFormalRecordByExerciseType(et: et) {
                latest = doneRecord
            } else {
                if let l = Training.getStrategy().recordList {
                    for r in l {
                        if r.exerciseType != et.rawValue {
                            continue
                        }
                        latest = r
                        break
                    }
                }
            }
            let min = et.MinWeight()
            GlobalInst.logger.info("max: \(latest == nil ? min : (latest!.weight < min ? min : latest!.weight))")
            let (max, plateList) = calBar(weight: latest == nil ? min : (latest!.weight < min ? min : latest!.weight), needNext: true)
            GlobalInst.logger.info("Generator.gen:  min: \(min) max: \(max)")
            var curL: [Record.Data] = []

            // TODO 三组热身 三组正式组 改为配置
            var cntWarmUp: Int = 0
            var curWeight: Double = min
            while cntWarmUp < et.countOfWarmUpSet() || curWeight + 20 < max {
                var tmp: Record.Data = Record.Data()
                tmp.id = GlobalInst.GetMillisecondTimestamp()
                tmp.exerciseType = et.rawValue
                tmp.weight = curWeight
                tmp.restInSec = Int64(15 * (cntWarmUp + 1))
                tmp.rep = 5
                curL.append(tmp)

                cntWarmUp += 1
                if curWeight + 25 < max {
                    curWeight += 20
                }
            }
            var cntFormal: Int = 0
            while cntFormal < et.countOfFormalSet() {
                var tmp: Record.Data = Record.Data()
                tmp.id = GlobalInst.GetMillisecondTimestamp()
                tmp.exerciseType = et.rawValue
                tmp.weight = max
                tmp.restInSec = 120
                tmp.rep = 5
                curL.append(tmp)
                cntFormal += 1
            }

            l.append(contentsOf: curL)
        }
        return l
    }

    static public func calBar(weight : Double, needNext: Bool) -> (Double, [Double: Int]?) /* weight -> count */ {
        if weight <= 20 {
            return (20, [:])
        }

        let weight = weight - 20

        let all = PlateCfg.getAllWeight()

        if !needNext {
            if all[weight] == nil {
                return (0, nil)
            }
            return (weight + 20, all[weight])
        }

        var w : Double = 0
        var cfg : [Double: Int]? = nil
        for (_w, _cfg) in all {
            if _w > weight && (cfg == nil || _w < w) {
                w = _w
                cfg = _cfg
            }
        }

        return (w + 20, cfg)
    }
}


