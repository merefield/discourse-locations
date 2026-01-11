import SortableColumn from "./sortable-column";

const LocationsDistanceCell = <template>
  <SortableColumn
    @sortable={{@sortable}}
    @number="false"
    @order="distance"
    @activeOrder={{@activeOrder}}
    @changeSort={{@changeSort}}
    @ascending={{@ascending}}
    @name="distance"
  />
</template>;

export default LocationsDistanceCell;