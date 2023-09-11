//
//  Pro + Realm.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/10.
//

import UIKit
import RealmSwift

enum writeType {
    case add
    case update
}

protocol RealmDB {
    func read<T: Object>(object:T.Type) -> Results<T>
    func write<T: Object>(object:T, writetype:writeType)
    func delete<T: Object>(object:T)
    func sort<T: Object>(object:T.Type, byKeyPath: String, ascending:Bool) -> Results<T>
}

//Realm ropository pattern
class LDRealm:RealmDB {
    
    let realm = try! Realm()
    
    func getRealmLocation() {
        print("=====Realm 경로: ", realm.configuration.fileURL!)
    }
    
    func read<T: Object>(object: T.Type) -> Results<T> {
        
        return realm.objects(object)
    }
    
    func filter(searchBar:UISearchBar, complition:@escaping (Results<RealmModel>) -> ()) {
        
        let filteredData = read(object: RealmModel.self).where { result in
            result.title.contains( searchBar.text ?? String().emptyStrng, options: .caseInsensitive)
        }
        
        complition(filteredData)
    }

    
    func write<T: Object>(object: T, writetype: writeType )  {
        
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
    
    func delete<T: Object>(object: T)  {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    func sort<T: Object>(object: T.Type, byKeyPath: String, ascending: Bool) -> Results<T>  {
        return realm.objects(object).sorted(byKeyPath: byKeyPath, ascending: ascending)
    }
    
    func searchDeleteObject(key:String) -> RealmModel {
        guard let result = realm.object(ofType: RealmModel.self, forPrimaryKey: key)
        else { return RealmModel() }
        
        return result

    }
    
}
