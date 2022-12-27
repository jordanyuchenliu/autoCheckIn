//
//  AWSHandler.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-17.
//

import Foundation
import SwiftUI

class AWSHandler {
    var clinicID = UserDefaults.standard.string(forKey: "clinic_id")!
    
    
    func getDemo(hin: String, completion: ()->()) -> Dictionary<String, AnyObject>? {
        let link = "https://1l85zbicd4.execute-api.us-east-2.amazonaws.com/beta0/resource?"
        var request = URLRequest(url: URL(string: link + "clinicId=" + clinicID + "&" + "hin=" + hin)!)
        var result: Dictionary<String, AnyObject>?
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                result = json
            } catch {
                print(error.localizedDescription)
                result = nil
            }
            group.leave()
        }.resume()
        group.wait()
        print(result)
        completion()
        return result
    }
    func putDemo(updatedDemo: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>? {
        let link = URL(string: "https://39260nyv76.execute-api.us-east-2.amazonaws.com/beta0/resource")!
        var result: Dictionary<String, AnyObject>?
        var request = URLRequest(url: link)
        var demo = updatedDemo
        demo["clinicId"] = clinicID as AnyObject
        request.httpMethod = "PUT"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: demo, options: []) else {
            return result
        }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                result = json
            } catch {
                print(error.localizedDescription)
                result = nil
            }
            group.leave()
        }.resume()
        group.wait()
        return result
    }
    
    func postDemo(newDemo: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>? {
        print(newDemo)
        let link = URL(string: "https://5uwzblz6ve.execute-api.us-east-2.amazonaws.com/beta0/resource")!
        var result: Dictionary<String, AnyObject>?
        var request = URLRequest(url: link)
        var demo = newDemo
        demo["clinicId"] = clinicID as AnyObject
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        var curYear =  String(components.year!)
        var curMonth = String(components.month!)
        var curDay = String(components.day!)
        
        if curMonth.count == 1 {
            curMonth = "0"+curMonth
        }
        if curDay.count == 1 {
            curDay = "0"+curDay
        }
        
        
        demo["dateJoined"] = curYear + "-" + curMonth + "-" + curDay as AnyObject
        print(demo)
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: demo, options: []) else {
            return result
        }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                result = json
            } catch {
                print(error.localizedDescription)
                result = nil
            }
            group.leave()
        }.resume()
        group.wait()
        print(result)
        return result
    }
    
    //Get with clinicId
    func getProvider(completion: () -> ()) -> [Provider] {
        let link = "https://gkmfeyxkf3.execute-api.us-east-2.amazonaws.com/beta0/transactions?"
        var request = URLRequest(url: URL(string: link + "clinicId=" + clinicID)!)
        var result: Dictionary<String, AnyObject>?
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                result = json
            } catch {
                print(error.localizedDescription)
                result = nil
            }
            group.leave()
        }.resume()
        group.wait()
        let providerStr = result!["phyList"] as? String ?? ""
        let providers = providerStr.components(separatedBy: "|")
        
        var returnVal: [Provider] = []
        for provider in providers {
            returnVal.append(Provider(id: provider))
        }
        completion()
        return returnVal
        
    }
    
    // Add appointment
    func addAppointment(firstName: String, lastName: String, hin: String, physicianId: String, appointmentNote: String, completion: ()->()) -> Bool {
        print(physicianId)
        let link = URL(string: "https://8b8k9qcl41.execute-api.us-east-2.amazonaws.com/beta0/resource")!
        var result: Dictionary<String, AnyObject>?
        var request = URLRequest(url: link)
        var body: Dictionary<String, String> = [
            "appointmentNote": appointmentNote,
            "firstName": firstName,
            "lastName": lastName,
            "hin": hin,
            "physicianId": physicianId,
            "clinicId": clinicID
        ]
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            return false
        }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                result = json
            } catch {
                print(error.localizedDescription)
                result = nil
            }
            group.leave()
        }.resume()
        group.wait()
        print(result)
        let message = result!["message"] as! String
        completion()
        return message == "SUCCESS"
    }
}


