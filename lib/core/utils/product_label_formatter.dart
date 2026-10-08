String formatProductColor(String color) {
  switch (color.toLowerCase()) {
    case 'black':
      return '블랙';
    case 'washed black':
      return '워시드 블랙';
    case 'dark brown':
      return '다크 브라운';
    case 'brown':
      return '브라운';
    case 'taupe':
      return '토프';
    case 'stone':
      return '스톤';
    case 'sand':
      return '샌드';
    case 'ivory':
      return '아이보리';
    case 'cream':
      return '크림';
    case 'white':
      return '화이트';
    case 'grey':
      return '그레이';
    case 'graphite':
      return '그라파이트';
    case 'charcoal':
      return '차콜';
    case 'blue':
      return '블루';
    case 'indigo':
      return '인디고';
    default:
      return color;
  }
}
