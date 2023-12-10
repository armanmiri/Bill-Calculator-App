import SwiftUI

struct ContentView: View {
    @State private var price: String = ""
    @State private var applyDiscount: Bool = false
    @State private var discount: String = ""
    @State private var tipPercentage: Double = 15
    @State private var serviceFeePercentage: Double = 5
    @State private var total: Double = 0
    @State private var showTaxRates = false
    @State private var selectedTaxRate: Double = 0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bill Details")) {
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    
                    Toggle("Apply Discount or Gift Card?", isOn: $applyDiscount)
                    
                    if applyDiscount {
                        TextField("Amount", text: $discount)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Tip")) {
                    Slider(value: $tipPercentage, in: 0...30)
                    Text("Tip: \(tipPercentage, specifier: "%.0f")%")
                }

                Section(header: Text("Service Fee")) {
                    Slider(value: $serviceFeePercentage, in: 0...20)
                    Text("Service Fee: \(serviceFeePercentage, specifier: "%.0f")%")
                }

                Section {
                    Button("Select Tax Rate") {
                        showTaxRates = true
                    }
                    Text("Selected Tax Rate: \(selectedTaxRate, specifier: "%.2f")%")
                }

                Section {
                    Button("Calculate Total") {
                        self.calculateTotal()
                    }
                }

                Section(header: Text("Total")) {
                    Text("$\(total, specifier: "%.2f")")
                }
            }
            .navigationBarTitle("Check Calculator")
            .sheet(isPresented: $showTaxRates) {
                TaxRateSearchView(selectedRate: $selectedTaxRate)
            }
        }
    }

    func calculateTotal() {
        let priceValue = Double(price) ?? 0
        let discountValue = applyDiscount ? (Double(discount) ?? 0) : 0
        let tipAmount = priceValue * tipPercentage / 100
        let serviceFeeAmount = priceValue * serviceFeePercentage / 100
        let taxAmount = priceValue * selectedTaxRate / 100

        let discountedPrice = priceValue - discountValue
        total = discountedPrice + tipAmount + serviceFeeAmount + taxAmount
        total = max(total, 0) // Ensure total doesn't go negative
    }
}

struct TaxRate {
    var name: String  // e.g., "Santa Clara"
    var rate: Double  // e.g., 9.13
}

class TaxRatesViewModel: ObservableObject {
    @Published var taxRates: [TaxRate] = [
            TaxRate(name: "Orange County", rate: 7.75),
            TaxRate(name: "San Francisco", rate: 8.50),
            TaxRate(name: "San Jose", rate: 9.25),
            TaxRate(name: "Oakland", rate: 9.25),
            TaxRate(name: "San Mateo", rate: 9.00),
            TaxRate(name: "Santa Clara", rate: 9.25),
            TaxRate(name: "Alameda County", rate: 9.25),
            TaxRate(name: "Contra Costa", rate: 8.25),
            TaxRate(name: "Marin County", rate: 8.25),
            TaxRate(name: "Napa County", rate: 7.75),
            TaxRate(name: "Sonoma County", rate: 8.25),
            TaxRate(name: "Solano County", rate: 7.88)
    ]

    @Published var searchText: String = ""

    var filteredTaxRates: [TaxRate] {
        if searchText.isEmpty {
            return taxRates
        } else {
            return taxRates.filter { $0.name.contains(searchText) }
        }
    }
}

struct TaxRateSearchView: View {
    @ObservedObject var viewModel = TaxRatesViewModel()
    @Binding var selectedRate: Double

    var body: some View {
        List {
            ForEach(viewModel.filteredTaxRates, id: \.name) { taxRate in
                Button(action: {
                    self.selectedRate = taxRate.rate
                }) {
                    Text("\(taxRate.name): \(taxRate.rate, specifier: "%.2f")%")
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
