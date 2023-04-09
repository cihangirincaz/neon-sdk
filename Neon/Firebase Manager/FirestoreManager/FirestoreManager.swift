//
//  FirestoreManager.swift
//  NeonSDK
//
//  Created by Tuna Öztürk on 8.04.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



public class FirestoreManager{
    
    
    // Post Operations
    
    
    /// This function will delete any previous data on the document and override fields to document.
    public static func setDocument(path : [FirestoreReferance], fields : [String : Any]){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseDocumentRef(path)
        referance.setData(fields)
        addTimestamp(referance: referance)
    }
    
    ///  The object should be from Codable class. Ex : public class Country: Codable {}
    public static func setDocument(path : [FirestoreReferance], object : Encodable){
        
        
        let referance = FirestoreReferanceManager.shared.prepareFirebaseDocumentRef(path)
        
        do {
            try referance.setData(from: object)
            addTimestamp(referance: referance)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    /// If document not exist, this function won't work. It will change if it find fields in the document. It will add new fields, if exist but it won't any remove fields.
    public static func updateDocument(path : [FirestoreReferance], fields : [String : Any]){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseDocumentRef(path)
        referance.updateData(fields)
        addTimestamp(referance: referance)
    }
    
    /// This function won't delete sub-collections. You should delete all of the sub-documents one-by-one to delete sub-collections.
    public static func deleteDocument(path : [FirestoreReferance]){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseDocumentRef(path)
        referance.delete()
    }
    
    static func addTimestamp(referance :  DocumentReference){
        referance.updateData(["updatedAt" : FieldValue.serverTimestamp()])
    }
    
    
    
    
    
    // Get Operations
    
    
    public static func getDocument(path : [FirestoreReferance], completion : @escaping (_ documentID : String, _ documentData : [String : Any]) -> ()){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseDocumentRef(path)
        referance.getDocument { (document, error) in
            if let document = document, document.exists {
                let documentID = document.documentID
                let documentData = document.data()
                guard let documentData else {
                    print("Document couldn't fetched because it does not have any fields")
                    return
                }
                completion(documentID, documentData)
            } else {
                print("Document does not exist")
            }
        }
        
    }
    
    
    ///  The object should be from Codable class. Ex : public class Country: Codable {}
    public static func getDocument<T: Decodable>(path : [FirestoreReferance], objectType : T.Type, completion : @escaping (_ object : Encodable) -> ()){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseDocumentRef(path)
        referance.getDocument(as: objectType) { result in
            
            switch result {
            case .success(let object):
                if let encodableObject = object as? Encodable{
                    completion(encodableObject)
                }else{
                    print("Fetched object is not encodable")
                }
            case .failure(let error):
                print("Error decoding object: \(error)")
            }
        }
    }
    
    /// The path should take a collection referance. completion will be called one time for the every document fetched. It will give id and data of the document.
    public static func getDocuments(path : [FirestoreReferance], completion : @escaping (_ documentID : String, _ documentData : [String : Any]) -> ()){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseCollectionRef(path)
        referance.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let documentID = document.documentID
                    let documentData = document.data()
                    completion(documentID, documentData)
                }
            }
        }
        
    }
    
    // Realtime listening
    
    
    public enum WriteSource{
        case local
        case server
    }
    
    static var activeListeners = [ListenerRegistration]()
    
    public static func listenDocument(path : [FirestoreReferance], completion : @escaping ( _ documentData : [String : Any], _ source : WriteSource) -> ()){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseDocumentRef(path)
        let listener = referance.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
           
                let documentID = document.documentID
                let documentData = document.data()
                guard let documentData else {
                    print("Document couldn't fetched because it does not have any fields")
                    return
                }
            
                let source = document.metadata.hasPendingWrites ? WriteSource.local : WriteSource.server
                completion(documentData, source)
            }
        activeListeners.append(listener)
    }
    
    /// The path should take a collection referance. completion will be called one time for the every document updated. It will give id and data of the updated document.
    public static func listenDocuments(path : [FirestoreReferance], completion : @escaping (_ documentID : String, _ documentData : [String : Any], _ source : WriteSource, _ changeType :  DocumentChangeType) -> ()){
        let referance = FirestoreReferanceManager.shared.prepareFirebaseCollectionRef(path).whereField("updatedAt", isGreaterThanOrEqualTo: Date())
        let listener = referance.addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                guard let snapshot = querySnapshot else {
                          print("Error fetching snapshots: \(err!)")
                          return
                      }
                
                snapshot.documentChanges.forEach { diff in
                     let document = diff.document
                     let documentID = document.documentID
                     let documentData = document.data()
                     let source = document.metadata.hasPendingWrites ? WriteSource.local : WriteSource.server
                     completion(documentID, documentData, source, diff.type)
                    }
            }
        }
        
        activeListeners.append(listener)
        
    }
    /// This function will remove all of the active listeners.
    public static func removeActiveListeners(){
        
        for index in 0...activeListeners.count - 1{
            if index < activeListeners.count{
                let listener = activeListeners[index]
                listener.remove()
                print("Listener removed : \(listener.description)")
            }
        }
        activeListeners = []
    }
   

}
