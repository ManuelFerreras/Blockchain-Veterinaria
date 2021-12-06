pragma solidity >= 0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract Veterinaria {

    address duenoVeterinaria;

    struct identificacionMascota {
        uint256 idMascota;
        string nombreMascota;
        address duenoMascota;
    }

    struct servicioVeterinaria {
        string nombreServicio;
        uint256 precioServicio;
        bool estadoServicio;
    }

    string[] nombreServicios;
    mapping(string => servicioVeterinaria) servicios;

    mapping(uint256 => identificacionMascota) identificacionesMascotas;
    uint256 contadorMascotas = 0;

    mapping(address => uint256[]) mascotasEnPosicion;

    mapping(uint256 => string[]) serviciosTomadosPorMascota;

    // Constructor
    constructor() {

        // Settear el dueño
        duenoVeterinaria = msg.sender;

    }

    // Eventos
    event eventoNuevoServicio(string, uint256);
    event eventoServicioDesactivado(string);
    event eventoNuevaMascota(string, address, uint256);
    event eventoServicioTomado(uint, string);

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == duenoVeterinaria, "Solo el duenio puede hacer eso.");
        _;
    }

    modifier onlyOwnerOfPet(uint256 _idMascota) {
        require(msg.sender == identificacionesMascotas[_idMascota].duenoMascota, "No Eres el Duenio de la Mascota.");
        _;
    }

    function conseguirServicios() public view returns (string[] memory) {
        return nombreServicios;
    }

    function conseguirServicio(string memory _nombreServicio) public view returns (servicioVeterinaria memory) {
        return(servicios[_nombreServicio]);
    }

    function nuevoServicio(string memory _nombreServicio, uint256 _precioServicio) public onlyOwner {

        // Chequeamos que el precio sea válido
        require(_precioServicio > 0, "Precio invalido");

        // Creamos el Nuevo Servicio
        servicios[_nombreServicio] = servicioVeterinaria(_nombreServicio, _precioServicio * 1 ether, true); 
        nombreServicios.push(_nombreServicio);

        // Emitimos el evento
        emit eventoNuevoServicio(_nombreServicio, _precioServicio);

    }

    function desactivarServicio(string memory _nombreServicio) public onlyOwner {

        // Chequeamos que el servicio esté actualmente activo
        require(servicios[_nombreServicio].estadoServicio, "Servicio no activo.");

        // Desactivamos el servicio
        servicios[_nombreServicio].estadoServicio = false;

        // Emitimos el evento
        emit eventoServicioDesactivado(_nombreServicio);

    }

    function nuevaMascota(string memory _nombreMascota) public {
        
        // Creamos la nueva mascota
        mascotasEnPosicion[msg.sender].push(contadorMascotas);
        identificacionesMascotas[contadorMascotas] = identificacionMascota(contadorMascotas, _nombreMascota, msg.sender);

        // Emitimos el evento
        emit eventoNuevaMascota(_nombreMascota, msg.sender, contadorMascotas);

        // Incrementamos el contador de mascotas
        contadorMascotas++;

    }

    function tomarServicio(string memory _nombreServicio, uint256 _idMascota) public payable onlyOwnerOfPet(_idMascota) {

        // Chequeos
        require(servicios[_nombreServicio].estadoServicio, "El servicio no esta activo");
        require(msg.value >= servicios[_nombreServicio].precioServicio, "No se ha enviado suficiente ether.");

        // Devolvemos el ether de sobra que se ha enviado
        uint256 _sobrante = msg.value - servicios[_nombreServicio].precioServicio;
        payable(msg.sender).transfer(_sobrante);

        serviciosTomadosPorMascota[_idMascota].push(_nombreServicio);

        // Emitimos el evento
        emit eventoServicioTomado(_idMascota, _nombreServicio);

    }

    function conseguirServiciosTomadosPorMascota(uint256 _idMascota) public view onlyOwnerOfPet(_idMascota) returns(string[] memory) {
        return serviciosTomadosPorMascota[_idMascota];
    }

}