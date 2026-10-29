
Feature: Examen practico - Regresion bancaria


  Background:
    * url 'http://134.209.211.10:4001'
    * configure connectTimeout = 15000
    * configure readTimeout = 15000
    * configure headers = { 'x-channel': 'WEB' }
    * def generarCelular = function(){ return '9' + Math.floor(10000000 + Math.random() * 90000000) }


  Scenario: 1 - Registro de usuarios Emisor y Receptor
    * def celularEmisor = generarCelular()
    * def correoEmisor = 'emisor' + celularEmisor + '@example.com'

    Given path 'auth', 'v1', 'register'
    And request
    """
    {
      "phone": "#(celularEmisor)",
      "fullName": "Emisor Prueba QA",
      "email": "#(correoEmisor)",
      "pin": "123456"
    }
    """
    When method post
    Then status 201
    * print 'Registro Emisor:', response


  Scenario: 2 - Registro del usuario Receptor
    * def celularReceptor = generarCelular()
    * def correoReceptor = 'receptor' + celularReceptor + '@example.com'

    Given path 'auth', 'v1', 'register'
    And request
    """
    {
      "phone": "#(celularReceptor)",
      "fullName": "Receptor Prueba QA",
      "email": "#(correoReceptor)",
      "pin": "123456"
    }
    """
    When method post
    Then status 201
    And match response.message == 'Usuario creado exitosamente'
    And match response.user.id == '#string'
    * def idReceptor = response.user.id
    * print 'Registro Receptor:', response




  Scenario: 3 - Login del usuario Emisor
    * def celularLogin = '975278627'
    * def pinLogin = '123456'

    Given path 'auth', 'v1', 'login'
    And request
    """
    {
      "phone": "#(celularLogin)",
      "pin": "#(pinLogin)"
    }
    """
    When method post
    Then status 200
    And match response == '#object'
    * print 'Respuesta Login Emisor:', response




  Scenario: 4 - Transferencia del Emisor al Receptor

    # Registrar un receptor nuevo
    * def celularReceptor = generarCelular()
    * def correoReceptor = 'receptor' + celularReceptor + '@example.com'

    Given url 'http://134.209.211.10:4001/auth/v1/register'
    And header x-channel = 'WEB'
    And header Content-Type = 'application/json'
    And request
    """
    {
      "phone": "#(celularReceptor)",
      "fullName": "Receptor Prueba QA",
      "email": "#(correoReceptor)",
      "pin": "123456"
    }
    """
    When method post
    Then status 201
    * def idReceptor = response.user.id

    # Login del emisor
    * def celularLogin = '975278627'
    * def pinLogin = '123456'

    Given url 'http://134.209.211.10:4001/auth/v1/login'
    And header x-channel = 'WEB'
    And header Content-Type = 'application/json'
    And request
    """
    {
      "phone": "#(celularLogin)",
      "pin": "#(pinLogin)"
    }
    """
    When method post
    Then status 200
    * def tokenEmisor = response.token

    # Transferencia al receptor
    Given url 'http://134.209.211.10:4003/transaction/v1/transfer'
    And header x-channel = 'WEB'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request
    """
    {
      "recipientId": "#(idReceptor)",
      "amount": 450,
      "description": "Transferencia de prueba",
      "categoryId": "cat_food_1"
    }
    """
    When method post
    Then status 200
    And match response.status == 'COMPLETED'
    * print 'Resultado Transferencia:', response