import HealthKit

extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .walking: return "步行"
        case .running: return "跑步"
        case .cycling: return "骑行"
        case .swimming: return "游泳"
        case .yoga: return "瑜伽"
        case .pilates: return "普拉提"
        case .traditionalStrengthTraining, .functionalStrengthTraining: return "力量训练"
        case .highIntensityIntervalTraining: return "间歇训练"
        case .hiking: return "徒步"
        case .elliptical: return "椭圆机"
        case .jumpRope: return "跳绳"
        case .basketball: return "篮球"
        case .badminton: return "羽毛球"
        case .soccer: return "足球"
        default: return "其他运动"
        }
    }
}

extension HKWorkoutActivityType {
    var sfSymbolName: String {
        switch self {

        case .americanFootball: return "figure.american.football"
        case .australianFootball: return "figure.australian.football"
        case .baseball: return "baseball"
        case .basketball: return "figure.basketball"
        case .cricket: return "figure.cricket"
        case .soccer: return "figure.soccer"
        case .softball: return "figure.softball"
        case .volleyball: return "figure.volleyball"
        case .handball: return "figure.handball"
        case .lacrosse: return "figure.lacrosse"
        case .rugby: return "figure.rugby"
        case .waterPolo: return "figure.water.polo"

        case .traditionalStrengthTraining, .functionalStrengthTraining: return "dumbbell"
        case .coreTraining: return "figure.core.training"
        case .crossTraining, .mixedCardio: return "figure.mix"
        case .highIntensityIntervalTraining: return "flame"
        case .kickboxing, .boxing, .martialArts, .wrestling: return "figure.boxing"
        case .preparationAndRecovery, .cooldown: return "figure.cooldown"
        case .flexibility: return "figure.flexibility"
            
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .stairClimbing, .stairs: return "figure.stairs"
        case .hiking: return "figure.hiking"
        case .elliptical: return "figure.elliptical"
        case .jumpRope: return "figure.jump.rope"
        case .cycling, .handCycling: return "figure.outdoor.cycle"
        case .wheelchairWalkPace, .wheelchairRunPace: return "figure.roll"
        case .trackAndField: return "figure.track.and.field"

        case .swimming: return "figure.pool.swim"
        case .waterFitness: return "figure.water.fitness"
        case .waterSports: return "figure.water.pipe"
        case .underwaterDiving: return "figure.dive"
        case .surfingSports: return "figure.surfing"
        case .paddleSports: return "figure.sailing"
        
        case .snowSports: return "figure.skiing"
        case .crossCountrySkiing: return "figure.crosscountry.skiing"
        case .downhillSkiing: return "figure.skiing.downhill"
        case .snowboarding: return "figure.snowboarding"
        case .climbing: return "figure.climbing"
        case .fishing, .hunting: return "figure.outdoor.hang"
        
        case .yoga, .pilates, .barre: return "figure.yoga"
        case .mindAndBody, .taiChi: return "figure.mind.and.body"
        case .dance, .socialDance, .cardioDance, .danceInspiredTraining: return "figure.dance"
        case .gymnastics: return "figure.gymnastics"
        
        case .tennis, .tableTennis, .squash, .badminton, .racquetball, .pickleball: return "figure.tennis"

        case .archery: return "figure.archery"
        case .bowling: return "figure.bowling"
        case .curling: return "figure.curling"
        case .equestrianSports: return "figure.equestrian.sports"
        case .fencing: return "figure.fencing"
        case .golf: return "figure.golf"
        case .rowing: return "figure.rower"
        case .sailing: return "figure.sailing"
        case .skatingSports: return "figure.skating"
        case .discSports: return "figure.disc.sports"
        case .fitnessGaming: return "figure.fall"
        case .play: return "figure.and.child.holdinghands"
        case .swimBikeRun, .transition: return "figure.mixed.cardio"
        
        case .mixedMetabolicCardioTraining: return "figure.mix"
        case .other: return "questionmark.circle"
        default: return "figure.activity"
        }
    }
}
