import Foundation

struct Verb: Identifiable, Hashable {
    let id: String
    let irish: String
    let english: String
    let csvFilename: String

    static let allVerbs: [Verb] = [
        Verb(id: "bi", irish: "Bí", english: "To Be", csvFilename: "bi"),
        Verb(id: "abair", irish: "Abair", english: "To Say", csvFilename: "abair"),
        Verb(id: "beir", irish: "Beir", english: "To Catch", csvFilename: "beir"),
        Verb(id: "clois", irish: "Clois", english: "To Hear", csvFilename: "clois"),
        Verb(id: "dean", irish: "Déan", english: "To Do", csvFilename: "dean"),
        Verb(id: "faigh", irish: "Faigh", english: "To Get", csvFilename: "faigh"),
        Verb(id: "feic", irish: "Feic", english: "To See", csvFilename: "feic"),
        Verb(id: "ith", irish: "Ith", english: "To Eat", csvFilename: "ith"),
        Verb(id: "tabhair", irish: "Tabhair", english: "To Give", csvFilename: "tabhair"),
        Verb(id: "tar", irish: "Tar", english: "To Come", csvFilename: "tar"),
        Verb(id: "teigh", irish: "Téigh", english: "To Go", csvFilename: "teigh")
    ]
}

struct Conjugation: Identifiable {
    let id = UUID()
    let person: String
    let pronoun: String
    let form: String
    let tense: String
    let gmForm: String
    let english: String
    let standard: String

    var seanclo: String {
        toSeanclo(gmForm)
    }

    var displayIrish: String {
        gmForm.isEmpty ? standard : gmForm
    }

    var displaySeanclo: String {
        toSeanclo(displayIrish)
    }
}

func toSeanclo(_ text: String) -> String {
    guard !text.isEmpty else { return "" }

    let lenitionMap: [(String, String)] = [
        ("bh", "ḃ"), ("Bh", "Ḃ"), ("BH", "Ḃ"),
        ("ch", "ċ"), ("Ch", "Ċ"), ("CH", "Ċ"),
        ("dh", "ḋ"), ("Dh", "Ḋ"), ("DH", "Ḋ"),
        ("fh", "ḟ"), ("Fh", "Ḟ"), ("FH", "Ḟ"),
        ("gh", "ġ"), ("Gh", "Ġ"), ("GH", "Ġ"),
        ("mh", "ṁ"), ("Mh", "Ṁ"), ("MH", "Ṁ"),
        ("ph", "ṗ"), ("Ph", "Ṗ"), ("PH", "Ṗ"),
        ("sh", "ṡ"), ("Sh", "Ṡ"), ("SH", "Ṡ"),
        ("th", "ṫ"), ("Th", "Ṫ"), ("TH", "Ṫ")
    ]

    var result = text
    for (modern, seanclo) in lenitionMap {
        result = result.replacingOccurrences(of: modern, with: seanclo)
    }
    return result
}

func parseCSV(_ content: String) -> [Conjugation] {
    let lines = content.components(separatedBy: .newlines)
    var conjugations: [Conjugation] = []

    for (index, line) in lines.enumerated() {
        // Skip header line
        if index == 0 { continue }

        let columns = parseCSVLine(line)
        guard columns.count >= 7 else { continue }

        let person = columns[1]
        let pronoun = columns[2]
        let form = columns[3]
        let tense = columns[4]
        let gmForm = columns[5]
        let english = columns[6]
        let standard = columns.count > 7 ? columns[7] : ""

        // Skip empty rows
        guard !person.isEmpty else { continue }

        conjugations.append(Conjugation(
            person: person,
            pronoun: pronoun,
            form: form,
            tense: tense,
            gmForm: gmForm,
            english: english,
            standard: standard
        ))
    }

    return conjugations
}

func parseCSVLine(_ line: String) -> [String] {
    var result: [String] = []
    var current = ""
    var inQuotes = false

    for char in line {
        if char == "\"" {
            inQuotes.toggle()
        } else if char == "," && !inQuotes {
            result.append(current)
            current = ""
        } else {
            current.append(char)
        }
    }
    result.append(current)

    return result
}
