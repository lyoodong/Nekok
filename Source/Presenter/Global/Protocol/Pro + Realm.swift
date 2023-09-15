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
    func read<T: Object>(object:T.Type) -> Results<T>
    func write<T: Object>(object:T, writetype:WriteType)
    func delete<T: Object>(object:T)
    func sort<T: Object>(object:T.Type, byKeyPath: String, ascending:Bool) -> Results<T>
}

//Realm ropository pattern
class LDRealm:RealmDB {
    
    let realm = try! Realm()
    
    //불러오기
    func read<T: Object>(object: T.Type) -> Results<T> {
        
        return realm.objects(object).sorted(byKeyPath: "registeredDate", ascending: false)
    }
    
    //불러오기
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
    
    //정렬
    func sort<T: Object>(object: T.Type, byKeyPath: String, ascending: Bool) -> Results<T>  {
        return realm.objects(object).sorted(byKeyPath: byKeyPath, ascending: ascending)
    }
    
    //검색어로 결과 필터링
    func filter(searchBar:UISearchBar, complition:@escaping (Results<RealmModel>) -> ()) {
        
        let filteredData = read(object: RealmModel.self).where { result in
            result.title.contains( searchBar.text ?? String().emptyStrng, options: .caseInsensitive)
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


