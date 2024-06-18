List<String> getHashtags(String text) {
  List<String> tags = [];

  for (String word in text.split(' ')) {
    if (word.startsWith('#')) {
      tags.add(word.substring(1));
    }
  }

  return tags;
}
