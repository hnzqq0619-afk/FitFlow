import Foundation

enum PlanSchema {
    static var value: [String: Any] {
        let text: [String: Any] = ["type": "string"]
        let number: [String: Any] = ["type": "number", "minimum": 0]
        let video: [String: Any] = ["type": "null"]
        func object(_ properties: [String: Any]) -> [String: Any] {
            ["type": "object", "properties": properties, "required": Array(properties.keys).sorted(),
             "additionalProperties": false]
        }
        func array(_ item: [String: Any], count: Int? = nil) -> [String: Any] {
            var schema: [String: Any] = ["type": "array", "items": item]
            if let count { schema["minItems"] = count; schema["maxItems"] = count }
            return schema
        }
        let meal = object([
            "meal_type": ["type": "string", "enum": ["早餐", "午餐", "晚餐", "加餐"]],
            "name": text, "description": text, "portion": text,
            "source": ["type": "string", "enum": ["自制", "外卖"]], "order_notes": text,
            "calories": ["type": "integer", "minimum": 1], "protein": number, "carbs": number,
            "fat": number, "video_url": video
        ])
        let index: [String: Any] = ["type": "integer", "minimum": 1, "maximum": 7]
        let mealDay = object(["day_index": index, "day": text, "meals": array(meal)])
        let exercise = object(["name": text, "sets": text, "reps": text, "video_url": video])
        let workout = object([
            "day_index": index, "day": text, "title": text, "is_rest_day": ["type": "boolean"],
            "duration_minutes": ["type": "integer", "minimum": 0], "exercises": array(exercise)
        ])
        return object(["weekly_focus": text, "nutrition_advice": text,
                       "meal_plan": object(["daily_meal_plans": array(mealDay, count: 7)]),
                       "daily_plan": array(workout, count: 7)])
    }
}
