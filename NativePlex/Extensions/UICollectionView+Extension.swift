/*
Infomaniak Core - iOS
Copyright (C) 2021 Infomaniak Network SA

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

import UIKit

extension UICollectionView {
    public func register(cellView: AnyClass) {
        let name = String(describing: cellView.self)
        register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }

    public func dequeueReusableCell<CellClass: UICollectionViewCell>(type: CellClass.Type, for indexPath: IndexPath) -> CellClass {
        return dequeueReusableCell(withReuseIdentifier: String(describing: type.self), for: indexPath) as! CellClass
    }
}
