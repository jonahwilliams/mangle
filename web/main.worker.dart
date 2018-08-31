import 'package:mangle/src/events.dart';
import 'package:mangle/src/worker.dart';

void main() {
  largeTable();
}

void largeTable() {
  context.start(null);
  context.elementOpen('table');
  for (var i = 0; i < words.length; i++) {
    context.elementOpenStart('tr');
    context.eventListener(Event.mouseover, '$i');
    if (i.isEven) {
      context.attribute('style', 'background-color: white;');
    } else {
      context.attribute('style', 'background-color: gray;');
    }
    context.elementOpenEnd();
    context.boundary('$i');
    context.elementClose('tr');
  }
  context.elementClose('table');
  context.end();

  for (var i = 0; i < words.length; i++) {
    context.start('$i');
    for (int i = 1; i < 50; i++) {
      context.elementOpenStart('td');
      context.attribute('style', 'width: ${35 + (i * 10)}px; height: 35px; border: 1px solid grey;');
      context.elementOpenEnd();
      context.text(words[(i ~/ 10)]);
      context.elementClose('td');
    }
    context.end();
  }
  context.flush();
}

// A list of some words that start with 'A'.
final words = [
  "abolishes",
  "abolishing",
  "abolishment",
  "abolishments",
  "abolition",
  "abolitionary",
  "abolitionise",
  "abolitionised",
  "abolitionising",
  "abolitionism",
  "abolitionist",
  "abolitionists",
  "abolitionize",
  "abolitionized",
  "abolitionizing",
  "abolla",
  "abollae",
  "aboma",
  "abomas",
  "abomasa",
  "abomasal",
  "abomasi",
  "abomasum",
  "abomasus",
  "abomasusi",
  "abominability",
  "abominable",
  "abominableness",
  "abominably",
  "abominate",
  "abominated",
  "abominates",
  "abominating",
  "abomination",
  "abominations",
  "abominator",
  "abominators",
  "abomine",
  "abondance",
  "abongo",
  "abonne",
  "abonnement",
  "aboon",
  "aborad",
  "aboral",
  "aborally",
  "abord",
  "aboriginal",
  "aboriginality",
  "aboriginally",
  "aboriginals",
  "aboriginary",
  "aborigine",
  "aborigines",
  "aborning",
  "aborsement",
  "aborsive",
  "abort",
  "aborted",
  "aborter",
  "aborters",
  "aborticide",
  "abortient",
  "abortifacient",
  "abortin",
  "aborting",
  "abortional",
  "abortionist",
  "abortionists",
  "abortions",
  "abortive",
  "abortively",
  "abortiveness",
  "abortogenic",
  "aborts",
  "abortus",
  "abortuses",
  "abos",
  "abote",
  "abouchement",
  "aboudikro",
  "abought",
  "aboulia",
  "aboulias",
  "aboulic",
  "abound",
  "abounded",
  "abounder",
  "abounding",
  "aboundingly",
  "abounds",
  "about",
  "abouts",
  "above",
  "aboveboard",
  "abovedeck",
  "aboveground",
  "abovementioned",
  "aboveproof",
  "aboves",
  "abovesaid",
  "abovestairs",
  "abow",
  "abox",
  "abp",
  "abr",
  "abracadabra",
  "abrachia",
  "abrachias",
  "abradable",
  "abradant",
  "abradants",
  "abrade",
  "abraded",
  "abrader",
  "abraders",
  "abrades",
  "abrading",
  "abraham",
  "abrahamic",
  "abrahamidae",
  "abrahamite",
  "abrahamitic",
  "abray",
  "abraid",
  "abram",
  "abramis",
  "abranchial",
  "abranchialism",
  "abranchian",
  "abranchiata",
  "abranchiate",
  "abranchious",
  "abrasax",
  "abrase",
  "abrased",
  "abraser",
  "abrash",
  "abrasing",
  "abrasiometer",
  "abrasion",
];
