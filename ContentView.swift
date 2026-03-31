import SwiftUI

struct ContentView: View {
    @State private var selectedVerb: Verb = Verb.allVerbs[0]
    @State private var conjugations: [Conjugation] = []
    @State private var selectedTense: String = "All"
    @State private var selectedForm: String = "All"
    @State private var selectedPersonPronoun: String = "All"

    // Maintain order from CSV (use first occurrence order)
    var personPronouns: [String] {
        var seen = Set<String>()
        var result = ["All"]
        for conj in conjugations {
            let combined = "\(conj.person) - \(conj.pronoun)"
            if !seen.contains(combined) {
                seen.insert(combined)
                result.append(combined)
            }
        }
        return result
    }

    var forms: [String] {
        var seen = Set<String>()
        var result = ["All"]
        for conj in conjugations {
            if !seen.contains(conj.form) {
                seen.insert(conj.form)
                result.append(conj.form)
            }
        }
        return result
    }

    var tenses: [String] {
        var seen = Set<String>()
        var result = ["All"]
        for conj in conjugations {
            if !seen.contains(conj.tense) {
                seen.insert(conj.tense)
                result.append(conj.tense)
            }
        }
        return result
    }

    var filteredConjugations: [Conjugation] {
        conjugations.filter { conj in
            let personPronounMatch: Bool
            if selectedPersonPronoun == "All" {
                personPronounMatch = true
            } else {
                let combined = "\(conj.person) - \(conj.pronoun)"
                personPronounMatch = combined == selectedPersonPronoun
            }
            return personPronounMatch &&
            (selectedTense == "All" || conj.tense == selectedTense) &&
            (selectedForm == "All" || conj.form == selectedForm)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Verb selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Verb.allVerbs) { verb in
                            Button(action: {
                                selectedVerb = verb
                                loadConjugations()
                            }) {
                                Text(verb.irish)
                                    .font(.system(size: 16, weight: selectedVerb.id == verb.id ? .bold : .regular))
                                    .foregroundColor(selectedVerb.id == verb.id ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedVerb.id == verb.id ? Color.green : Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)

                // Title
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Text(selectedVerb.irish)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("-")
                            .font(.title)
                        Text(toSeanclo(selectedVerb.irish))
                            .font(.custom("Gadelica", size: 28))
                        Text("-")
                            .font(.title)
                        Text(selectedVerb.english)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 12)

                // Filters
                VStack(spacing: 8) {
                    HStack {
                        HStack(spacing: 4) {
                            Text("Person:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Person", selection: $selectedPersonPronoun) {
                                ForEach(personPronouns, id: \.self) { pp in
                                    Text(pp).tag(pp)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    HStack {
                        HStack(spacing: 4) {
                            Text("Tense:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Tense", selection: $selectedTense) {
                                ForEach(tenses, id: \.self) { tense in
                                    Text(tense).tag(tense)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("Form:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Form", selection: $selectedForm) {
                                ForEach(forms, id: \.self) { form in
                                    Text(form).tag(form)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Conjugations table
                List(filteredConjugations) { conj in
                    HStack(alignment: .top, spacing: 12) {
                        // Left side: Irish
                        VStack(alignment: .leading, spacing: 4) {
                            if !conj.displayIrish.isEmpty {
                                Text(conj.displayIrish)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text(conj.displaySeanclo)
                                    .font(.custom("Gadelica", size: 17))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        // Right side: Tense, Form, English
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Text(conj.tense)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(4)
                                Text(conj.form)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }

                            Text(conj.english + (conj.form.contains("Interrogative") ? "?" : ""))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadConjugations()
        }
    }

    func loadConjugations() {
        if let url = Bundle.main.url(forResource: selectedVerb.csvFilename, withExtension: "csv"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            conjugations = parseCSV(content)
        }
    }
}

#Preview {
    ContentView()
}
