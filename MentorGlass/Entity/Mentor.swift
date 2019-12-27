//
//  Mentor.swift
//  MentorGlass
//
//  Created by Ren Matsushita on 2019/12/27.
//  Copyright © 2019 Ren Matsushita. All rights reserved.
//

import Foundation

struct Mentor {
    let id: String
    let name: String
    let corse: String
    let university: String
    let description: String
    let facebookURL: URL
}

struct Mentors {
    static private let items: [Mentor] = [
        Mentor(
            id: "ka-ki",
            name: "カーキ",
            corse: "Android",
            university: "名古屋工業大学",
            description: "三度の飯よりカレーが好き",
            facebookURL: URL(string: "https://www.facebook.com/profile.php?id=100004233513748")!
        ),
        Mentor(
            id: "robato",
            name: "ロバート",
            corse: "iPhone",
            university: "大阪府立大学",
            description: "名前の由来はロバート秋山ではない",
            facebookURL: URL(string: "https://www.facebook.com/profile.php?id=100018486043154")!
        ),
        Mentor(
            id: "osuzu",
            name: "おすず",
            corse: "キャメラ",
            university: "早稲田大学",
            description: "学習に苦労した",
            facebookURL: URL(string: "https://www.facebook.com/marin.suzuki21")!
        )
    ]
    
    static func search(id: String) -> Mentor {
        for item in self.items {
            if item.id == id {
                return item
            }
        }
        return Mentor(id: "id", name: "name", corse: "iPhone", university: "東京大学", description: "架空の人物", facebookURL: URL(string: "https://facebook.com")!)
    }
}
