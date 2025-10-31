import { useEffect, useState, type ChangeEvent } from "react";
import {
  ActionIcon,
  AppShell,
  Button,
  Grid,
  Group,
  LoadingOverlay,
  NumberInput,
  Paper,
  ScrollArea,
  SegmentedControl,
  Stack,
  Text,
  TextInput,
  Title
} from "@mantine/core";
import { IconLogout, IconRefresh } from "@tabler/icons-react";
import { generateSignal, fetchSignalHistory } from "../api/signals";
import type { InstrumentType, SignalParameters, SignalResponse } from "../types/api";
import type { SignalRequest } from "../types/api";
import { useAuthStore } from "../store/auth";
import { SignalSummaryCard } from "../components/SignalSummaryCard";

const defaultParams: SignalParameters = {
  short_window: 14,
  long_window: 50,
  rsi_period: 14,
  rsi_overbought: 70,
  rsi_oversold: 30,
  volume_window: 20,
  volatility_window: 20
};

const instrumentOptions: Array<{ label: string; value: InstrumentType }> = [
  { label: "Ações", value: "equity" },
  { label: "Mini Índice", value: "mini_indice" },
  { label: "Mini Dólar", value: "mini_dolar" }
];

const timeframeOptions: SignalRequest["timeframe"][] = [
  "1m",
  "5m",
  "15m",
  "1h",
  "1d",
  "1wk",
  "1mo"
];

export default function DashboardPage(): JSX.Element {
  const { email, logout } = useAuthStore();
  const [instrument, setInstrument] = useState<InstrumentType>("equity");
  const [timeframe, setTimeframe] = useState<SignalRequest["timeframe"]>("1d");
  const [symbol, setSymbol] = useState("");
  const [params, setParams] = useState<SignalParameters>(defaultParams);
  const [currentSignal, setCurrentSignal] = useState<SignalResponse | null>(null);
  const [history, setHistory] = useState<SignalResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadHistory = async () => {
    setHistoryLoading(true);
    try {
      const response = await fetchSignalHistory(instrument, 20);
      setHistory(response.items);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Falha ao carregar histórico");
    } finally {
      setHistoryLoading(false);
    }
  };

  useEffect(() => {
    void loadHistory();
  }, [instrument]);

  const handleGenerate = async () => {
    setLoading(true);
    setError(null);
    try {
      const payload: SignalRequest = {
        instrument_type: instrument,
        symbol: symbol.trim() || undefined,
        timeframe,
        parameters: params
      };
      const signal = await generateSignal(payload);
      setCurrentSignal(signal);
  setHistory((prev: SignalResponse[]) => [signal, ...prev].slice(0, 20));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Falha ao gerar sinal");
    } finally {
      setLoading(false);
    }
  };

  const updateParam = (key: keyof SignalParameters, value: number | string | null) => {
    if (typeof value !== "number") {
      return;
    }
  setParams((prev: SignalParameters) => ({ ...prev, [key]: value }));
  };

  return (
    <AppShell padding="md" header={{ height: 60 }}>
      <AppShell.Header>
        <Group justify="space-between" align="center" px="md" h="100%">
          <Title order={3}>ROBX Signals</Title>
          <Group gap="sm">
            <Text size="sm" c="dimmed">
              {email}
            </Text>
            <ActionIcon variant="light" color="red" onClick={logout} aria-label="Sair">
              <IconLogout size={18} />
            </ActionIcon>
          </Group>
        </Group>
      </AppShell.Header>
      <AppShell.Main>
        <LoadingOverlay visible={loading} overlayProps={{ radius: "sm", blur: 2 }} />
        <Stack gap="lg">
          <Paper shadow="xs" radius="md" withBorder p="md">
            <Stack>
              <Group justify="space-between" align="flex-end" wrap="wrap">
                <SegmentedControl
                  value={instrument}
                  onChange={(value: string) => setInstrument(value as InstrumentType)}
                  data={instrumentOptions}
                />
                <SegmentedControl
                  value={timeframe}
                  onChange={(value: string) => setTimeframe(value as SignalRequest["timeframe"])}
                  data={timeframeOptions.map((value) => ({ label: value, value }))}
                />
                <TextInput
                  label="Ativo"
                  placeholder="Ex: PETR4.SA"
                  value={symbol}
                  onChange={(event: ChangeEvent<HTMLInputElement>) =>
                    setSymbol(event.currentTarget.value.toUpperCase())
                  }
                />
              </Group>
              <Grid>
                <Grid.Col span={{ base: 12, md: 6, lg: 4 }}>
                  <NumberInput
                    label="Média curta"
                    value={params.short_window}
                    min={3}
                    max={120}
                    onChange={(value: number | string) => updateParam("short_window", value)}
                  />
                </Grid.Col>
                <Grid.Col span={{ base: 12, md: 6, lg: 4 }}>
                  <NumberInput
                    label="Média longa"
                    value={params.long_window}
                    min={10}
                    max={240}
                    onChange={(value: number | string) => updateParam("long_window", value)}
                  />
                </Grid.Col>
                <Grid.Col span={{ base: 12, md: 6, lg: 4 }}>
                  <NumberInput
                    label="Período RSI"
                    value={params.rsi_period}
                    min={2}
                    max={60}
                    onChange={(value: number | string) => updateParam("rsi_period", value)}
                  />
                </Grid.Col>
                <Grid.Col span={{ base: 12, md: 6, lg: 4 }}>
                  <NumberInput
                    label="RSI sobrecompra"
                    value={params.rsi_overbought}
                    min={50}
                    max={90}
                    onChange={(value: number | string) => updateParam("rsi_overbought", value)}
                  />
                </Grid.Col>
                <Grid.Col span={{ base: 12, md: 6, lg: 4 }}>
                  <NumberInput
                    label="RSI sobrevenda"
                    value={params.rsi_oversold}
                    min={10}
                    max={50}
                    onChange={(value: number | string) => updateParam("rsi_oversold", value)}
                  />
                </Grid.Col>
                <Grid.Col span={{ base: 12, md: 6, lg: 4 }}>
                  <NumberInput
                    label="Janela volume"
                    value={params.volume_window}
                    min={5}
                    max={120}
                    onChange={(value: number | string) => updateParam("volume_window", value)}
                  />
                </Grid.Col>
                <Grid.Col span={{ base: 12, md: 6, lg: 4 }}>
                  <NumberInput
                    label="Janela volatilidade"
                    value={params.volatility_window}
                    min={5}
                    max={120}
                    onChange={(value: number | string) => updateParam("volatility_window", value)}
                  />
                </Grid.Col>
              </Grid>
              <Group justify="space-between">
                {error && (
                  <Text c="red" size="sm">
                    {error}
                  </Text>
                )}
                <Button leftSection={<IconRefresh size={16} />} onClick={handleGenerate}>
                  Gerar sinal
                </Button>
              </Group>
            </Stack>
          </Paper>
          <Grid>
            <Grid.Col span={{ base: 12, lg: 6 }}>
              {currentSignal ? (
                <SignalSummaryCard signal={currentSignal} />
              ) : (
                <Paper withBorder radius="md" p="xl" ta="center">
                  <Stack align="center" gap="sm">
                    <Title order={4}>Nenhum sinal ainda</Title>
                    <Text c="dimmed" size="sm">
                      Ajuste os parâmetros e gere o primeiro sinal do dia.
                    </Text>
                  </Stack>
                </Paper>
              )}
            </Grid.Col>
            <Grid.Col span={{ base: 12, lg: 6 }}>
              <Paper withBorder radius="md" p="md" h="100%">
                <Stack gap="sm" h="100%">
                  <Group justify="space-between">
                    <Title order={5}>Histórico recente</Title>
                    <Button variant="light" compact onClick={() => void loadHistory()} leftSection={<IconRefresh size={14} />}>
                      Atualizar
                    </Button>
                  </Group>
                  <ScrollArea h={360} type="always">
                    <Stack>
                      {historyLoading && <Text c="dimmed">Carregando histórico...</Text>}
                      {!historyLoading && history.length === 0 && (
                        <Text c="dimmed" size="sm">
                          Sem histórico disponível.
                        </Text>
                      )}
                      {history.map((item: SignalResponse) => (
                        <Paper key={item.created_at + item.symbol} shadow="xs" radius="md" p="sm" withBorder>
                          <Group justify="space-between" align="flex-start">
                            <Stack gap={0}>
                              <Text fw={600}>{item.symbol}</Text>
                              <Text size="xs" c="dimmed">
                                {new Date(item.created_at).toLocaleString("pt-BR")}
                              </Text>
                            </Stack>
                            <Text fw={600} c={item.recommendation === "buy" ? "teal" : item.recommendation === "sell" ? "red" : "gray"}>
                              {item.recommendation.toUpperCase()}
                            </Text>
                          </Group>
                          <Text size="sm" mt="xs">
                            {item.summary}
                          </Text>
                        </Paper>
                      ))}
                    </Stack>
                  </ScrollArea>
                </Stack>
              </Paper>
            </Grid.Col>
          </Grid>
        </Stack>
      </AppShell.Main>
    </AppShell>
  );
}
