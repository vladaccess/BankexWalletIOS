//
//  WalletsDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


extension WalletsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let wallet = listWallets[indexPath.row]
            service.updateSelected(address: wallet.address)
            delegate?.didTapped(with: wallet)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}