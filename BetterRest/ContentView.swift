//
//  ContentView.swift
//  BetterRest
//
//  Created by Gurur on 17.06.2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    @State private var wakeUp: Date = defaultWakeTime
    @State private var sleepAmount: Double = 8.0
    @State private var coffeeAmount: Int = 1
    
    @State private var estimatedBedTime: Date?
    
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var showAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
//                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                    Picker("Select", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text($0 == 1 ? "\($0) cup" : "\($0) cups")
                        }
                    }
                }
                
                Section("Estimated bedtime") {
                    Text(estimatedBedTime?.formatted(date: .omitted, time: .shortened) ?? "–")
                }
            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedTime)
//            }
//            .alert(alertTitle, isPresented: $showAlert) {
//                Button("OK") {}
//            } message: {
//                Text(alertMessage)
//            }
            .onAppear {
                calculateBedTime()
            }
            .onChange(of: wakeUp) { _, _ in calculateBedTime() }
            .onChange(of: sleepAmount) { _, _ in calculateBedTime() }
            .onChange(of: coffeeAmount) { _, _ in calculateBedTime() }
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            estimatedBedTime = sleepTime
            
//            alertTitle = "Ideal bed time"
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
//            alertTitle = "Error"
//            alertMessage = "Sorry, there was a problem calculating your bedtime."
            estimatedBedTime = nil
        }
        
//        showAlert = true
    }
}

#Preview {
    ContentView()
}
