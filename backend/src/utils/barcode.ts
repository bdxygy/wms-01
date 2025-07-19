import { customAlphabet } from "nanoid";
import { env } from "../config/env";

const nanoidGenerator = customAlphabet("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", 8);

export const generateBarcode = () => env.BARCODE_PREFIX + nanoidGenerator();
