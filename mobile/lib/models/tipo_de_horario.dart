enum TipoDeHorario {
      Semanal,
      PorFecha,
      Unico,
      Desconocido; // Para un valor por defecto o en caso de error de parseo

      // # Este es un método convertido a programación funcional
      static TipoDeHorario fromString(String? typeString) {
        switch (typeString?.toLowerCase().replaceAll(' ', '')) { // Normalizar string
          case 'semanal':
            return TipoDeHorario.Semanal;
          case 'porfecha':
            return TipoDeHorario.PorFecha;
          case 'unico':
          case 'único':
            return TipoDeHorario.Unico;
          default:
            print('TipoDeHorario desconocido recibido: $typeString');
            return TipoDeHorario.Desconocido;
        }
      }

      String get displayName {
        switch (this) {
          case TipoDeHorario.Semanal:
            return 'Semanal';
          case TipoDeHorario.PorFecha:
            return 'Por Fecha';
          case TipoDeHorario.Unico:
            return 'Único';
          case TipoDeHorario.Desconocido:
            return 'Desconocido';
        }
      }
    } 