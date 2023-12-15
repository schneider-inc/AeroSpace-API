import HotKey

let keysMap: [String: Key] = [
    "a": .a,
    "b": .b,
    "c": .c,
    "d": .d,
    "e": .e,
    "f": .f,
    "g": .g,
    "h": .h,
    "i": .i,
    "j": .j,
    "k": .k,
    "l": .l,
    "m": .m,
    "n": .n,
    "o": .o,
    "p": .p,
    "q": .q,
    "r": .r,
    "s": .s,
    "t": .t,
    "u": .u,
    "v": .v,
    "w": .w,
    "x": .x,
    "y": .y,
    "z": .z,

    "0": .zero,
    "1": .one,
    "2": .two,
    "3": .three,
    "4": .four,
    "5": .five,
    "6": .six,
    "7": .seven,
    "8": .eight,
    "9": .nine,

    "keypad0": .keypad0,
    "keypad1": .keypad1,
    "keypad2": .keypad2,
    "keypad3": .keypad3,
    "keypad4": .keypad4,
    "keypad5": .keypad5,
    "keypad6": .keypad6,
    "keypad7": .keypad7,
    "keypad8": .keypad8,
    "keypad9": .keypad9,
    "keypadClear": .keypadClear,
    "keypadDecimalMark": .keypadDecimal,
    "keypadDivide": .keypadDivide,
    "keypadEnter": .keypadEnter,
    "keypadEqual": .keypadEquals,
    "keypadMinus": .keypadMinus,
    "keypadMultiply": .keypadMultiply,
    "keypadPlus": .keypadPlus,

    "f1": .f1,
    "f2": .f2,
    "f3": .f3,
    "f4": .f4,
    "f5": .f5,
    "f6": .f6,
    "f7": .f7,
    "f8": .f8,
    "f9": .f9,
    "f10": .f10,
    "f11": .f11,
    "f12": .f12,
    "f13": .f13,
    "f14": .f14,
    "f15": .f15,
    "f16": .f16,
    "f17": .f17,
    "f18": .f18,
    "f19": .f19,
    "f20": .f20,

    "minus": .minus,
    "equal": .equal,
    "period": .period,
    "comma": .comma,
    "slash": .slash,
    "backslash": .backslash,
    "quote": .quote,
    "semicolon": .semicolon,
    "backtick": .grave,
    "leftSquareBracket": .leftBracket,
    "rightSquareBracket": .rightBracket,
    "space": .space,
    "enter": .return,
    "esc": .escape,
    "backspace": .delete,
    "tab": .tab,

    "left": .leftArrow,
    "down": .downArrow,
    "up": .upArrow,
    "right": .rightArrow,
]

let modifiersMap: [String: NSEvent.ModifierFlags] = [
    "shift": .shift,
    "alt": .option,
    "ctrl": .control,
    "cmd": .command,
]

// doesn't work :(
//extension NSEvent.ModifierFlags {
//    static let lOption = NSEvent.ModifierFlags(rawValue: 1 << 1)
//    static let rOption = NSEvent.ModifierFlags(rawValue: 1 << 2)
//    static let lShift = NSEvent.ModifierFlags(rawValue: 0x00000002)
//    static let rShift = NSEvent.ModifierFlags(rawValue: 0x00000004)
//    static let lCommand = NSEvent.ModifierFlags(rawValue: 1 << 7)
//    static let rCommand = NSEvent.ModifierFlags(rawValue: 0x00000010)
//}

// NSEvent.ModifierFlags.command.rawValue // 1 << 20
// NSEvent.ModifierFlags.option.rawValue // 1 << 19
// NSEvent.ModifierFlags.control.rawValue // 1 << 18
// NSEvent.ModifierFlags.shift.rawValue // 1 << 17
// https://github.com/koekeishiya/skhd/blob/master/src/hotkey.h