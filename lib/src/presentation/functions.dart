String capitalizeWord(String word) {
  return word
      .split('')
      .indexed
      .map((e) => e.$1 == 0 ? e.$2.toUpperCase() : e.$2)
      .join('');
}
