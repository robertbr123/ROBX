import { useState, type ChangeEvent } from "react";
import { useNavigate } from "react-router-dom";
import {
  Anchor,
  Button,
  Group,
  Paper,
  PasswordInput,
  Stack,
  Text,
  TextInput,
  Title
} from "@mantine/core";
import { login, registerUser } from "../api/auth";
import { useAuthStore } from "../store/auth";

export default function LoginPage(): JSX.Element {
  const navigate = useNavigate();
  const setAuth = useAuthStore((state) => state.setAuth);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [mode, setMode] = useState<"login" | "register">("login");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    setLoading(true);
    setError(null);
    try {
      if (mode === "register") {
        await registerUser(email, fullName, password);
      }
      const token = await login(email, password);
      setAuth(token.access_token, email);
      navigate("/");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Falha na autenticação");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Stack miw={{ base: "100%", sm: 420 }} mah="100vh" justify="center" align="center" px="md">
      <Paper shadow="md" radius="lg" p="xl" withBorder style={{ width: "100%" }}>
        <Stack>
          <Title order={2} ta="center">
            ROBX Signals
          </Title>
          <Text c="dimmed" ta="center">
            {mode === "login" ? "Entre para acessar seus sinais premium" : "Crie sua conta para começar"}
          </Text>
          {mode === "register" && (
            <TextInput
              label="Nome completo"
              placeholder="Seu nome"
              value={fullName}
              onChange={(event: ChangeEvent<HTMLInputElement>) =>
                setFullName(event.currentTarget.value)
              }
            />
          )}
          <TextInput
            label="E-mail"
            placeholder="voce@empresa.com"
            type="email"
            value={email}
            onChange={(event: ChangeEvent<HTMLInputElement>) =>
              setEmail(event.currentTarget.value)
            }
          />
          <PasswordInput
            label="Senha"
            placeholder="Sua senha"
            value={password}
            onChange={(event: ChangeEvent<HTMLInputElement>) =>
              setPassword(event.currentTarget.value)
            }
          />
          {error && (
            <Text c="red" size="sm">
              {error}
            </Text>
          )}
          <Button loading={loading} onClick={handleSubmit} fullWidth>
            {mode === "login" ? "Entrar" : "Registrar e entrar"}
          </Button>
          <Group justify="center">
            <Text size="sm" c="dimmed">
              {mode === "login" ? "Novo por aqui?" : "Já possui conta?"}
            </Text>
            <Anchor size="sm" onClick={() => setMode(mode === "login" ? "register" : "login")}>
              {mode === "login" ? "Crie uma conta" : "Ir para login"}
            </Anchor>
          </Group>
        </Stack>
      </Paper>
    </Stack>
  );
}
