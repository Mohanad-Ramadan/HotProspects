//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Mohanad Ramdan on 06/09/2023.
//
import CodeScanner
import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case contacted, notContacted, none
    }
    enum SortBy {
        case name, recent
    }
    
    let filter : FilterType
    @State private var sortedBy : SortBy = .name
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var showingSort = false
    
    var body: some View {
        NavigationView {
            List{
                ForEach(filterdProspects){ prospect in
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(prospect.isContacted ? .green : .red)
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            if prospect.isContacted {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                                }
                                .tint(.blue)
                            } else {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                                }
                                .tint(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button{
                        showingSort = true
                    } label: {
                        Label("Erase", systemImage: "folder.fill.badge.minus")
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Mor Ramadan\nMohanadm1@icloud.com", completion: handleScan)
            }
            .confirmationDialog("sort by", isPresented: $showingSort){
                Button("Name"){
                    sortedBy = .name
                }
                Button("Recent"){
                    sortedBy = .recent
                }
            }
        }
    }
    
    var title : String {
        switch filter {
        case .contacted: return "Contacted People"
        case .notContacted : return "Uncontacted People"
        case .none: return "Everyone"
        }
    }
    var filterdProspects : [Prospect] {
        switch filter {
        case .contacted:
            return sortProspects.filter {$0.isContacted}
        case .notContacted:
            return sortProspects.filter {!$0.isContacted}
        case .none:
            return sortProspects
        }
    }
    var sortProspects: [Prospect] {
        switch sortedBy {
        case .name:
            return prospects.people.sorted(by: { $0.name < $1.name })
        case .recent:
            return prospects.people.sorted(by: { $0.date < $1.date })
        }
    }
    func handleScan(result: Result<ScanResult,ScanError>){
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)
            
        case .failure(let error):
            print("error when scanning case: \(error.localizedDescription)")
        }
    }
    
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
