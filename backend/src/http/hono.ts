
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { User } from "../models";

export interface Applications {
  Variables: {
    user: User;
  };
}

export const createApp = () => {
  const app = new Hono<Applications>();
  
  // Global error handler
  app.onError((err, c) => {
    if (err instanceof HTTPException) {
      // Return the error as-is if it's already an HTTPException
      return err.getResponse();
    }
    
    console.error('Unhandled error:', err);
    
    // Return generic 500 error for unexpected errors
    return c.json(
      {
        message: 'Internal Server Error',
        status: 500,
      },
      500
    );
  });
  
  return app;
};
