import { Colors } from "bibata-core/src/types";

interface Config {
  themeName: string;
  color: Colors;
}

const black = "#353535";
const white = "#D4C4C4";
const amber = "#FF8300";
const richBlack = "#525252";

const config: Config[] = [
  {
    themeName: "Bibata-Modern-Amber",
    color: {
      base: amber,
      outline: white,
      watch: {
        background: richBlack,
      },
    },
  },
  {
    themeName: "Bibata-Modern-Classic",
    color: {
      base: black,
      outline: white,
    },
  },
  {
    themeName: "Bibata-Modern-Ice",
    color: {
      base: white,
      outline: black,
    },
  },
];

export { config };
