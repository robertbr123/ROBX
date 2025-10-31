import api from "./client";
import { InstrumentType, SignalHistoryResponse, SignalRequest, SignalResponse } from "../types/api";

export async function generateSignal(request: SignalRequest): Promise<SignalResponse> {
  const { data } = await api.post<SignalResponse>("/signals", request);
  return data;
}

export async function fetchSignalHistory(
  instrument?: InstrumentType,
  limit: number = 20
): Promise<SignalHistoryResponse> {
  const { data } = await api.get<SignalHistoryResponse>("/signals/history", {
    params: { instrument, limit }
  });
  return data;
}
