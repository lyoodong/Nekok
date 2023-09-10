//
//  Pro + Realm.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/10.
//

import UIKit
import RealmSwift

public enum writeType {
    case add
    case update
}

protocol RealmDB {
    func read<T: Object>(object:T.Type) -> Results<T>
    func write<T: Object>(object:T, writetype:writeType)
    func delete<T: Object>(object:T)
    func sort<T: Object>(object:T.Type, byKeyPath: String, ascending:Bool) -> Results<T>
}

public class LDRealm:RealmDB {
    static let shared = LDRealm()
    
    init() {}
    
    let realm = try! Realm()
    
    public func getRealmLocation() {
        print("=====Realm 경로: ", realm.configuration.fileURL!)
    }
    
    public func read<T: Object>( object: T.Type) -> Results<T> {
        return realm.objects(object)
    }
    
    public func write<T: Object>(object: T, writetype: writeType )  {
        
        switch writetype {
        case .add:
            do {
                try realm.write {
                    realm.add(object)
                }
            } catch {
                print(error)
            }
        case .update:
            do {
                try realm.write {
                    realm.add(object, update: .modified)
                }
            } catch {
                print(error)
            }
            
        }
    }
    
    public func delete<T: Object>(object: T)  {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    public func sort<T: Object>(object: T.Type, byKeyPath: String, ascending: Bool) -> Results<T>  {
        return realm.objects(object).sorted(byKeyPath: byKeyPath, ascending: ascending)
    }
    
}

