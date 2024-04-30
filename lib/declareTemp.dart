

class DeclareTemp{
  static List<Map<String,dynamic>> stockin_card = [];
  static List<Map<String,dynamic>> sale_recript = [];

  static bool isStockDupp(String addingBarcode,String addingUnitid){
    for(int i=0;i < stockin_card.length;i++){
      String barcode = stockin_card[i]['barcode'].toString();
      String unitid = stockin_card[i]['unitid'].toString();
      if(addingBarcode.toUpperCase() == barcode.toUpperCase()
          && addingUnitid.toUpperCase() == unitid.toUpperCase() ){
        return true;
      }
    }

    return false;
  }

  static bool StockRemove(String remBarcode){
    for(int i=0;i < stockin_card.length;i++){
      String barcode = stockin_card[i]['barcode'].toString();
      if(remBarcode.toUpperCase() == barcode.toUpperCase()){
        stockin_card.removeAt(i);
        return true;
      }
    }

    return false;
  }

}