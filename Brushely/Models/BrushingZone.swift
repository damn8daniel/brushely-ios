import Foundation
import SwiftUI

// MARK: - Brushing Zone Model

struct BrushingZone: Identifiable, Equatable {
    let id: Int
    let name: String
    let shortName: String
    let instruction: String
    let motionHint: String
    let imageName: String         // asset catalog image name
    let jaw: Jaw
    let side: Side
    let surface: Surface
    let duration: TimeInterval
    
    enum Jaw: String { case upper = "Верхняя", lower = "Нижняя" }
    enum Side: String { case left = "Левая", right = "Правая", front = "Передняя", full = "Вся" }
    enum Surface: String { case outer = "Наружная", inner = "Внутренняя", chewing = "Жевательная" }
}

// MARK: - Standard 8-Zone Brushing Sequence

extension BrushingZone {
    static let standardSequence: [BrushingZone] = [
        BrushingZone(
            id: 0, name: "Верхние правые — наружная", shortName: "В.Пр. ↗",
            instruction: "Наклоните щётку под 45° к десне.\nВыметающие движения от десны к краю зуба.",
            motionHint: "↕️ Вверх-вниз", imageName: "zone_side",
            jaw: .upper, side: .right, surface: .outer, duration: 15
        ),
        BrushingZone(
            id: 1, name: "Верхние передние — наружная", shortName: "В.Перед. ↑",
            instruction: "Держите щётку вертикально.\nМягкие выметающие движения сверху вниз.",
            motionHint: "↕️ Сверху вниз", imageName: "zone_front",
            jaw: .upper, side: .front, surface: .outer, duration: 15
        ),
        BrushingZone(
            id: 2, name: "Верхние левые — наружная", shortName: "В.Лев. ↖",
            instruction: "Наклоните щётку под 45° к десне.\nВыметающие движения от десны к краю зуба.",
            motionHint: "↕️ Вверх-вниз", imageName: "zone_side",
            jaw: .upper, side: .left, surface: .outer, duration: 15
        ),
        BrushingZone(
            id: 3, name: "Нижние левые — наружная", shortName: "Н.Лев. ↙",
            instruction: "Наклоните щётку под 45° к десне.\nВыметающие движения от десны к краю зуба.",
            motionHint: "↕️ Снизу вверх", imageName: "zone_side",
            jaw: .lower, side: .left, surface: .outer, duration: 15
        ),
        BrushingZone(
            id: 4, name: "Нижние передние — наружная", shortName: "Н.Перед. ↓",
            instruction: "Держите щётку вертикально.\nМягкие выметающие движения снизу вверх.",
            motionHint: "↕️ Снизу вверх", imageName: "zone_front",
            jaw: .lower, side: .front, surface: .outer, duration: 15
        ),
        BrushingZone(
            id: 5, name: "Нижние правые — наружная", shortName: "Н.Пр. ↘",
            instruction: "Наклоните щётку под 45° к десне.\nВыметающие движения от десны к краю зуба.",
            motionHint: "↕️ Снизу вверх", imageName: "zone_side",
            jaw: .lower, side: .right, surface: .outer, duration: 15
        ),
        BrushingZone(
            id: 6, name: "Верхняя — жевательные", shortName: "В.Жеват.",
            instruction: "Горизонтальные возвратно-поступательные\nдвижения по жевательной поверхности.",
            motionHint: "↔️ Вперёд-назад", imageName: "zone_chewing",
            jaw: .upper, side: .full, surface: .chewing, duration: 15
        ),
        BrushingZone(
            id: 7, name: "Нижняя — жевательные", shortName: "Н.Жеват.",
            instruction: "Горизонтальные возвратно-поступательные\nдвижения по жевательной поверхности.",
            motionHint: "↔️ Вперёд-назад", imageName: "zone_chewing",
            jaw: .lower, side: .full, surface: .chewing, duration: 15
        ),
    ]
}
