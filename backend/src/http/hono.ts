
import { Hono } from "hono";
import { User } from "../models";

export interface Applications {
  Variables: {
    user: User;
  };
}

export const createApp = () => {
  return new Hono<Applications>();
};
