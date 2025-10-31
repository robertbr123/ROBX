import api from "./client";
import { TokenResponse } from "../types/api";

export async function login(email: string, password: string): Promise<TokenResponse> {
  const form = new URLSearchParams();
  form.set("username", email);
  form.set("password", password);
  const { data } = await api.post<TokenResponse>("/auth/login", form, {
    headers: { "Content-Type": "application/x-www-form-urlencoded" }
  });
  return data;
}

export async function registerUser(
  email: string,
  fullName: string,
  password: string
): Promise<void> {
  await api.post("/auth/register", {
    email,
    full_name: fullName,
    password
  });
}
