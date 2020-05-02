tipeaValor(String type, var valor){
  var value;

  switch(type){
    case 'option':
      value = valor != null ? int.parse(valor) : null;
      break;
    case 'numeric':
      var isNum = isNumeric('$valor');

      if(isNum){
        value = valor != null ? double.parse(valor) : null;
      }else{
        value = null;
      }

      break;
    case 'text':
      value = valor;
      break;
    case 'bool':
      print('boooooool: $valor');
      value = valor;
      break;
    default:
      value = null;
      break;
  }

  return value;
}

bool isNumeric(String str) {
  if(str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}
