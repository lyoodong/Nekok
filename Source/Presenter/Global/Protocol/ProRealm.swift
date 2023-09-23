//
//  Pro + Realm.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/10.
//

import UIKit
import RealmSwift

//기본 메서드
protocol RealmDB {
    func read<T: Object>(object:T.Type, readtype: ReadType, bykeyPath: String?) -> Results<T>
    func write<T: Object>(object:T, writetype:WriteType)
    func delete<T: Object>(object:T)
}

enum realmError: Int, Error {
    case notFoundRealmDB
}

//Realm ropository pattern
class LDRealm:RealmDB {
    
    var realm = try! Realm()
    
    //
//    init?() throws {
//        do {
//            self.realm = try Realm()
//        } catch {
//            throw realmError.notFoundRealmDB
//        }
//    }
    
    //불러오기
    func read<T: Object>(object: T.Type, readtype: ReadType, bykeyPath: String?) -> Results<T> {
        
        if readtype == .read {
            return realm.objects(object).sorted(byKeyPath: "registeredDate", ascending: false)
        } else if readtype == .sort {
            return realm.objects(object).sorted(byKeyPath: bykeyPath!, ascending: true)
        } else {
            return realm.objects(object).filter("error")
        }
    }
    
    //쓰기
    func write<T: Object>(object: T, writetype: WriteType )  {
        
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
    
    //삭제
    func delete<T: Object>(object: T)  {
        
        try! realm.write {
            realm.delete(object)
            
        }
    }

    
    //검색어로 결과 필터링
    func filter(searchBar:UISearchBar, complition:@escaping (Results<RealmModel>) -> ()) {
        
        let filteredData = read(object: RealmModel.self, readtype: .read, bykeyPath: nil).where { result in
            result.title.contains( searchBar.text ?? "", options: .caseInsensitive)
        }
        
        complition(filteredData)

    }
    
    
    //파일 경로
    func getRealmLocation() {
        print("=====Realm 경로: ", realm.configuration.fileURL!)
    }
    
    //PK로 레코드 가져오기
    func readByPrimaryKey<T: Object>(object: T.Type, productID:String) -> RealmModel {
        guard let result = realm.object(ofType: RealmModel.self, forPrimaryKey: productID) else { return RealmModel() }
        return result
    }
    
    //PK로 레코드 삭제하기
    func searchDeleteObject(key:String) -> RealmModel {
        guard let result = realm.object(ofType: RealmModel.self, forPrimaryKey: key)
        else { return RealmModel() }
        
        return result
    }
}


