import { Badge, Card, Group, RingProgress, Stack, Text } from "@mantine/core";
import { IconArrowUpRight, IconMinus, IconTrendingDown } from "@tabler/icons-react";
import type { SignalResponse } from "../types/api";

interface Props {
  signal: SignalResponse;
}

const recommendationConfig = {
  buy: { color: "teal", label: "Compra", icon: IconArrowUpRight },
  sell: { color: "red", label: "Venda", icon: IconTrendingDown },
  hold: { color: "gray", label: "Neutro", icon: IconMinus }
} as const;

export function SignalSummaryCard({ signal }: Props): JSX.Element {
  const config = recommendationConfig[signal.recommendation];
  const Icon = config.icon;
  return (
    <Card shadow="sm" radius="md" withBorder>
      <Stack gap="sm">
        <Group justify="space-between">
          <Stack gap={0}>
            <Text size="xl" fw={600}>
              {signal.symbol}
            </Text>
            <Text size="sm" c="dimmed">
              {new Date(signal.created_at).toLocaleString("pt-BR")}
            </Text>
          </Stack>
          <RingProgress
            size={120}
            thickness={10}
            sections={[{ value: signal.confidence * 100, color: config.color }]}
            label={<Text fw={600}>{Math.round(signal.confidence * 100)}%</Text>}
          />
        </Group>
        <Group>
          <Badge color={config.color} radius="sm" leftSection={<Icon size={16} />}>
            {config.label}
          </Badge>
          <Badge variant="light" color="blue">
            {signal.instrument_type.replace("_", " ").toUpperCase()}
          </Badge>
          <Badge variant="light" color="grape">
            {signal.timeframe}
          </Badge>
        </Group>
        <Text>{signal.summary}</Text>
        <Stack gap="xs">
          {Object.entries(signal.indicators).map(([key, value]) => (
            <Group key={key} justify="space-between">
              <Text size="sm" c="dimmed">
                {key.replace(/_/g, " ").toUpperCase()}
              </Text>
              <Text size="sm" fw={500}>
                {value}
              </Text>
            </Group>
          ))}
        </Stack>
      </Stack>
    </Card>
  );
}
