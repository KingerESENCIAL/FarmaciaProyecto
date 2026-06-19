using MySql.Data.MySqlClient;

var builder = WebApplication.CreateBuilder(args);

var cadenaConexion =
    "server=127.0.0.1;database=farmacia;user=root;password=1234;";

var app = builder.Build();

app.MapGet("/", () => "API Farmacia funcionando");

// Registro de usuario

app.MapPost("/registro", async (HttpContext context) =>
{
    var form = await context.Request.ReadFormAsync();

    string usuario = form["usuario"];
    string password = form["password"];

   string conexion = cadenaConexion;

    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = @"INSERT INTO usuarios(usuario,password)
                   VALUES(@usuario,@password)";

    using var cmd = new MySqlCommand(sql, conn);

    cmd.Parameters.AddWithValue("@usuario", usuario);
    cmd.Parameters.AddWithValue("@password", password);

    cmd.ExecuteNonQuery();

    return Results.Ok("Usuario registrado");
});
app.MapGet("/prueba", () =>
{
    string conexion = cadenaConexion;
    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = "INSERT INTO usuarios(usuario,password) VALUES('angel','123')";

    using var cmd = new MySqlCommand(sql, conn);
    cmd.ExecuteNonQuery();

    return "Usuario agregado";
});

app.MapGet("/login", (string usuario, string password) =>
{
    string conexion = cadenaConexion;

    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = "SELECT COUNT(*) FROM usuarios WHERE usuario=@usuario AND password=@password";

    using var cmd = new MySqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("@usuario", usuario);
    cmd.Parameters.AddWithValue("@password", password);

    int existe = Convert.ToInt32(cmd.ExecuteScalar());

    if (existe > 0)
        return "Login correcto";

    return "Usuario o contraseña incorrectos";
});

app.MapGet("/agregarMedicamento",
(string nombre,
 string laboratorio,
 int cantidad,
 string fecha_caducidad,
 string ubicacion) =>
{
    string conexion = cadenaConexion;

    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = @"INSERT INTO medicamentos
                  (nombre,laboratorio,cantidad,fecha_caducidad,ubicacion)
                  VALUES
                  (@nombre,@laboratorio,@cantidad,@fecha,@ubicacion)";

    using var cmd = new MySqlCommand(sql, conn);

    cmd.Parameters.AddWithValue("@nombre", nombre);
    cmd.Parameters.AddWithValue("@laboratorio", laboratorio);
    cmd.Parameters.AddWithValue("@cantidad", cantidad);
    cmd.Parameters.AddWithValue("@fecha", fecha_caducidad);
    cmd.Parameters.AddWithValue("@ubicacion", ubicacion);

    cmd.ExecuteNonQuery();

    return "Medicamento agregado";
});

app.MapGet("/medicamentos", () =>
{
    string conexion = cadenaConexion;

    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = "SELECT * FROM medicamentos";

    using var cmd = new MySqlCommand(sql, conn);

    using var reader = cmd.ExecuteReader();

    var medicamentos = new List<object>();

    while (reader.Read())
    {
        medicamentos.Add(new
        {
            id = reader["id"],
            nombre = reader["nombre"],
            laboratorio = reader["laboratorio"],
            cantidad = reader["cantidad"],
            fecha_caducidad = reader["fecha_caducidad"],
            ubicacion = reader["ubicacion"]
        });
    }

    return medicamentos;
});

app.MapGet("/buscarMedicamento", (string nombre) =>
{
    string conexion = cadenaConexion;

    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = "SELECT * FROM medicamentos WHERE nombre LIKE @nombre";

    using var cmd = new MySqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("@nombre", "%" + nombre + "%");

    using var reader = cmd.ExecuteReader();

    var medicamentos = new List<object>();

    while (reader.Read())
    {
        medicamentos.Add(new
        {
            id = reader["id"],
            nombre = reader["nombre"],
            laboratorio = reader["laboratorio"],
            cantidad = reader["cantidad"],
            fecha_caducidad = reader["fecha_caducidad"],
            ubicacion = reader["ubicacion"]
        });
    }

    return medicamentos;
});

app.MapPut("/actualizarMedicamento",
(int id,
 string nombre,
 string laboratorio,
 int cantidad,
 string fecha_caducidad,
 string ubicacion) =>
{
    string conexion = cadenaConexion;

    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = @"UPDATE medicamentos
                   SET nombre=@nombre,
                       laboratorio=@laboratorio,
                       cantidad=@cantidad,
                       fecha_caducidad=@fecha,
                       ubicacion=@ubicacion
                   WHERE id=@id";

    using var cmd = new MySqlCommand(sql, conn);

    cmd.Parameters.AddWithValue("@id", id);
    cmd.Parameters.AddWithValue("@nombre", nombre);
    cmd.Parameters.AddWithValue("@laboratorio", laboratorio);
    cmd.Parameters.AddWithValue("@cantidad", cantidad);
    cmd.Parameters.AddWithValue("@fecha", fecha_caducidad);
    cmd.Parameters.AddWithValue("@ubicacion", ubicacion);

    cmd.ExecuteNonQuery();

    return "Medicamento actualizado";
});

app.MapDelete("/eliminarMedicamento", (int id) =>
{
    string conexion = cadenaConexion;

    using var conn = new MySqlConnection(conexion);
    conn.Open();

    string sql = "DELETE FROM medicamentos WHERE id=@id";

    using var cmd = new MySqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("@id", id);

    cmd.ExecuteNonQuery();

    return "Medicamento eliminado";
});

app.Run();