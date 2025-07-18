import { User } from "@/models";
import { Hono } from "hono";

export interface Applications {
  Variables: {
    user: User;
  };
}

export const createApp = () => {
  return new Hono<Applications>();
};
